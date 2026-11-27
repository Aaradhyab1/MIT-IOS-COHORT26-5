import Foundation
import Observation

/// Sentences: read a phrase, sentence or paragraph aloud while the words light up.
/// One ViewModel plays all four categories; only the passages differ.
///
/// Flow per passage: idle → reading ⇄ paused → completed (accuracy) → next passage.
/// Tapping any word opens the pronunciation sheet (and pauses reading first).
/// The screen's states are listed in `SentencesPracticePhase`.
///
/// When a passage ends:
/// - straight away once the last word is heard correctly;
/// - after a short pause once every word has been tried but the last one was wrong or
///   is still being recognised (the recogniser often revises it), so a wrong last word
///   neither ends the passage early nor keeps the child waiting;
/// - after a long silence on the last couple of words (a mumbled or skipped ending).
/// In the last two cases the recogniser is asked for its final words first, and the
/// accuracy is worked out from those.
@Observable
@MainActor
final class SentencesPracticeViewModel {
    /// A long silence ends the passage only when this few words (or fewer) are left.
    static let wordsLeftForSilenceToEnd = 2

    private(set) var phase: SentencesPracticePhase = .idle
    private(set) var passageIndex = 0
    /// The current word. Words before it are green (said right) or red (not yet).
    private(set) var readCount = 0
    /// Words said correctly.
    private(set) var correctWords: Set<Int> = []
    /// Words passed without being said correctly; saying one again turns it green.
    private(set) var incorrectWords: Set<Int> = []

    /// The word whose pronunciation sheet is open.
    var selectedWord: ReadingWord?
    private(set) var isSayingWord = false

    let title: String
    private let exerciseId: String
    private let passages: [ReadingPassage]
    private let reader: any ReadAloudService
    private let voice: any SpeechSynthesisService
    private let progress: any ProgressRepository
    private let router: AppRouter

    private var tracker: ReadingTracker
    /// What the recogniser heard in each listening session of this passage
    /// (pausing and resuming starts a new session).
    private var heardSessions: [[HeardWord]] = []
    /// Latest score of each passage, by passage index, for Progress.
    private var passageResults: [Int: SentencesResult] = [:]
    private var task: Task<Void, Never>?
    /// The child is done; waiting for the recogniser's final words before scoring.
    private var isFinishing = false

    init(
        exerciseId: String,
        content: any ContentRepository,
        reader: any ReadAloudService,
        voice: any SpeechSynthesisService,
        progress: any ProgressRepository,
        router: AppRouter
    ) {
        let exercise = content.exercise(id: exerciseId)
        self.exerciseId = exerciseId
        self.title = exercise?.title ?? "Sentences"
        let passages = (exercise?.items ?? []).map(ReadingPassage.init)
        self.passages = passages
        self.tracker = ReadingTracker(words: passages.first?.words.map(\.spoken) ?? [])
        self.reader = reader
        self.voice = voice
        self.progress = progress
        self.router = router
    }

    // MARK: - What the screen shows

    var words: [ReadingWord] { currentPassage?.words ?? [] }

    /// "Sentence 1 of 3" when the exercise has more than one passage.
    var positionText: String? {
        passages.count > 1 ? "Sentence \(passageIndex + 1) of \(passages.count)" : nil
    }

    func highlight(for word: ReadingWord) -> WordHighlight {
        if correctWords.contains(word.id) { return .read }
        if incorrectWords.contains(word.id) { return .incorrect }
        if phase == .reading && word.id == readCount { return .current }
        return .none
    }

    /// Line under the microphone.
    var status: String? {
        switch phase {
        case .idle: nil
        case .reading: "Reading aloud…"
        case .paused: "Tap to continue reading"
        case .noSpeech: "I didn't hear any words. Tap the mic and read aloud."
        case .interrupted: "Reading stopped for a call or another app. Tap to keep reading."
        case .recognitionFailed: "I couldn't follow that. Tap the mic to keep reading."
        case .micFailed(.noMicrophone): "No microphone found. Connect one, or try on an iPhone."
        case .micFailed(.recognizerUnavailable): "Speech recognition isn't available right now. Tap to try again."
        case .micFailed(.audioFailed): "The microphone didn't start. Tap to try again."
        case .micDenied: "Allow the microphone and speech access to read aloud."
        case .completed: nil
        }
    }

    var showsMicrophone: Bool {
        switch phase {
        case .micDenied, .completed: false
        default: true
        }
    }

    var isReading: Bool { phase == .reading }

    var isLastPassage: Bool { passageIndex >= passages.count - 1 }

    /// The score of the passage just read.
    var result: SentencesResult? {
        if case .completed(let result) = phase { return result }
        return nil
    }

    // MARK: - Reading

    /// The mic button: start, pause, or carry on reading.
    func didTapMicrophone() {
        if phase == .reading {
            pause()
        } else {
            startReading()
        }
    }

    func startReading() {
        guard currentPassage != nil, !tracker.isFinished, result == nil else { return }
        task?.cancel()
        voice.stop()
        task = Task {
            guard await reader.requestPermission() else {
                phase = .micDenied
                return
            }
            guard !Task.isCancelled else { return }
            listen()
        }
    }

    /// Starts a listening session from the current word. Words read before are kept.
    private func listen() {
        guard let passage = currentPassage else { return }
        isFinishing = false
        heardSessions.append([])
        let failure = reader.start(
            expecting: passage.text(from: tracker.position),
            onHeard: { [weak self] heard in self?.didHear(heard) },
            onQuiet: { [weak self] quiet in self?.didGoQuiet(quiet) },
            onStopped: { [weak self] reason in self?.didStopListening(reason) }
        )
        if let failure {
            heardSessions.removeLast()
            phase = .micFailed(failure)
        } else {
            phase = .reading
        }
    }

    /// Stops listening; the next tap carries on from the current word.
    /// Also used when the app goes to the background.
    func pause() {
        guard phase == .reading else { return }
        reader.stop()
        isFinishing = false
        phase = .paused
    }

    /// New words from the recogniser. It sends everything heard in this session each time,
    /// often rewriting earlier words, so the whole passage is lined up again every time.
    private func didHear(_ heard: [HeardWord]) {
        guard phase == .reading else { return }
        if !heardSessions.isEmpty { heardSessions[heardSessions.count - 1] = heard }
        updateTracker(settled: false)
        // The last word said right: nothing left to wait for.
        if tracker.isFinished && tracker.isLastWordCorrect { finishPassage() }
    }

    private func didGoQuiet(_ quiet: ReadAloudQuiet) {
        guard phase == .reading, !isFinishing, hasHeardWords else { return }
        switch quiet {
        case .pause:
            // Every word tried, the last one wrong or half heard: the child has finished.
            // A pause with words still unread is just a breath.
            if tracker.isFinished || (tracker.isHearingCurrentWord && tracker.remainingCount == 1) {
                endReading()
            }
        case .long:
            if tracker.remainingCount <= Self.wordsLeftForSilenceToEnd { endReading() }
        }
    }

    /// Asks the recogniser for its final words; the score follows in `didStopListening`.
    private func endReading() {
        isFinishing = true
        reader.finish()
    }

    /// Listening ended by itself.
    /// - After `endReading()`: score the passage with the final words.
    /// - A phone call, another app or an audio route change: keep every word read so far.
    /// - The recogniser finished after hearing something: near the end the passage is
    ///   done; otherwise (a long pause or its time limit) keep listening straight away.
    /// - It heard nothing, or failed: say so; the child taps the mic to carry on.
    private func didStopListening(_ reason: ReadAloudStop) {
        guard phase == .reading else { return }
        if isFinishing, reason != .interrupted, hasHeardWords {
            finishPassage()
            return
        }
        isFinishing = false
        let heardInSession = heardSessions.last?.isEmpty == false
        switch reason {
        case .interrupted:
            phase = .interrupted
        case .recognizerEnded where heardInSession && tracker.remainingCount <= ReadingTracker.lookAhead:
            finishPassage()
        case .recognizerEnded where heardInSession:
            listen()
            if phase != .reading { phase = .recognitionFailed }
        case .recognizerEnded:
            phase = hasHeardWords ? .paused : .noSpeech
        case .failed:
            phase = .recognitionFailed
        }
    }

    private var heardWords: [HeardWord] {
        heardSessions.flatMap { $0 }
    }

    private var hasHeardWords: Bool { !heardWords.isEmpty }

    private func updateTracker(settled: Bool) {
        tracker.align(heard: heardWords, settled: settled)
        readCount = tracker.position
        correctWords = tracker.matched
        incorrectWords = tracker.incorrect
    }

    private func finishPassage() {
        reader.stop()
        isFinishing = false
        // Nothing recognised: no score, so a silent passage can't look finished.
        guard hasHeardWords else {
            phase = .noSpeech
            return
        }
        updateTracker(settled: true)
        let result = SentencesResult(correctWords: tracker.correctCount, totalWords: tracker.expectedCount)
        passageResults[passageIndex] = result
        if isLastPassage { saveProgress() }
        phase = .completed(result)
    }

    // MARK: - Pronunciation sheet

    /// Tapping a word pauses reading and opens its pronunciation sheet.
    func didTapWord(_ word: ReadingWord) {
        pause()
        selectedWord = word
    }

    func didTapHearPronunciation() {
        guard let word = selectedWord, !isSayingWord else { return }
        isSayingWord = true
        Task {
            await voice.speak(word.spoken, slowly: true)
            isSayingWord = false
        }
    }

    func didCloseSheet() {
        voice.stop()
        isSayingWord = false
        selectedWord = nil
    }

    // MARK: - Moving on

    /// Completion screen's main button: "Next sentence", or "Back to home" after the last.
    var continueTitle: String { isLastPassage ? "Back to home" : "Next sentence" }

    func didTapContinue() {
        guard result != nil else { return }
        if isLastPassage {
            stopAll()
            router.popToRoot()
        } else {
            showPassage(passageIndex + 1)
        }
    }

    /// Completion screen, below 90 %: read this passage again from a clean slate.
    func didTapTryAgain() {
        stopAll()
        passageResults[passageIndex] = nil
        showPassage(passageIndex)
    }

    /// Back button: asks "Leave this practice?" using the shared overlay.
    func didTapBack() {
        pause()
        router.presentLeavePractice()
    }

    /// Stops listening and the voice. The screen calls it when it disappears,
    /// including after "Leave" on the shared overlay.
    func stopAll() {
        task?.cancel()
        reader.stop()
        voice.stop()
        isFinishing = false
        if phase == .reading { phase = .paused }
    }

    // MARK: - Private

    private var currentPassage: ReadingPassage? {
        passages.indices.contains(passageIndex) ? passages[passageIndex] : nil
    }

    /// Shows a passage with nothing read yet.
    private func showPassage(_ index: Int) {
        passageIndex = index
        tracker = ReadingTracker(words: words.map(\.spoken))
        heardSessions = []
        isFinishing = false
        readCount = tracker.position
        correctWords = []
        incorrectWords = []
        selectedWord = nil
        phase = .idle
    }

    /// Saves every passage's words for Progress once the last passage is read.
    private func saveProgress() {
        let results = passageResults.values
        let correct = results.map(\.correctWords).reduce(0, +)
        let total = results.map(\.totalWords).reduce(0, +)
        _ = progress.finish(exerciseId: exerciseId, correct: correct, total: max(total, 1))
    }
}
