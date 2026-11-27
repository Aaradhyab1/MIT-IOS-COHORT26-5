import Foundation
import Observation

/// Sentences: read a sentence, rhyme or short story aloud while the words light up.
/// One ViewModel plays all four categories (2 word combinations, 3 word phrases,
/// Expanding sentences, Short stories & nursery rhymes); only the passages differ.
///
/// Flow per passage: idle → reading ⇄ paused → completed (accuracy) → next passage.
/// Tapping any word opens the pronunciation sheet (and pauses reading first).
/// After every passage its accuracy is worked out with `ReadingAccuracy` and the
/// completion screen shows it. The screen's states are listed in `SentencesPracticePhase`.
@Observable
@MainActor
final class SentencesPracticeViewModel {
    /// A passage ends by itself when the child has reached its last few words and then
    /// stays quiet this long (the recogniser may never hear the very last word exactly).
    static let endOfReadingSilence: Duration = .seconds(3)

    private(set) var phase: SentencesPracticePhase = .idle
    private(set) var passageIndex = 0
    /// Next word to read. Words before it were said (green) or missed (left plain).
    private(set) var readCount = 0
    /// Words the recogniser never heard, so they stay unhighlighted.
    private(set) var missedWords: Set<Int> = []

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
    private var silenceTask: Task<Void, Never>?

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
        if word.id < readCount { return missedWords.contains(word.id) ? .none : .read }
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
        case .interrupted: "The microphone stopped. Tap to keep reading."
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
        guard currentPassage != nil, !tracker.isFinished else { return }
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

    /// Starts a listening session from the next unread word.
    private func listen() {
        guard let passage = currentPassage else { return }
        tracker.beginSession()
        heardSessions.append([])
        let failure = reader.start(
            expecting: passage.text(from: tracker.position),
            onHeard: { [weak self] heard in self?.didHear(heard) },
            onStopped: { [weak self] in self?.didStopListening() }
        )
        phase = failure.map { SentencesPracticePhase.micFailed($0) } ?? .reading
    }

    func pause() {
        guard phase == .reading else { return }
        silenceTask?.cancel()
        reader.stop()
        phase = .paused
    }

    private func didHear(_ heard: [HeardWord]) {
        guard phase == .reading else { return }
        if !heardSessions.isEmpty { heardSessions[heardSessions.count - 1] = heard }
        tracker.update(heard: heard)
        readCount = tracker.position
        missedWords = tracker.skipped
        if tracker.isFinished {
            finishPassage()
        } else {
            waitForEndOfReading()
        }
    }

    /// When the child is on the last few words and goes quiet, the passage is done.
    private func waitForEndOfReading() {
        silenceTask?.cancel()
        guard tracker.words.count - tracker.position <= ReadingTracker.lookAhead else { return }
        silenceTask = Task {
            try? await Task.sleep(for: Self.endOfReadingSilence)
            guard !Task.isCancelled, phase == .reading else { return }
            finishPassage()
        }
    }

    /// The recogniser ended by itself (a long pause, its time limit, or an error).
    /// If this session heard something, keep listening from the next word, so a long
    /// rhyme isn't cut off; otherwise say that nothing was heard.
    private func didStopListening() {
        guard phase == .reading else { return }
        silenceTask?.cancel()
        if heardSessions.last?.isEmpty == false {
            listen()
            if phase != .reading { phase = .interrupted }
        } else {
            phase = hasHeardWords ? .interrupted : .noSpeech
        }
    }

    private var heardWords: [HeardWord] {
        heardSessions.flatMap { $0 }
    }

    private var hasHeardWords: Bool { !heardWords.isEmpty }

    private func finishPassage() {
        silenceTask?.cancel()
        reader.stop()
        let heard = heardWords
        guard !heard.isEmpty else {
            phase = .noSpeech
            return
        }
        let expected = tracker.words.filter { !$0.isEmpty }
        let result = SentencesResult(
            correctWords: ReadingAccuracy.correctWords(expected: expected, heard: heard),
            totalWords: expected.count
        )
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
        silenceTask?.cancel()
        reader.stop()
        voice.stop()
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
        readCount = tracker.position
        missedWords = []
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
