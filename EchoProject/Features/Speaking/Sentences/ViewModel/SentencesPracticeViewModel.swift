import Foundation
import Observation

/// Sentences: read a sentence, rhyme or short story aloud while the words light up.
/// One ViewModel plays all four categories (2 word combinations, 3 word phrases,
/// Expanding sentences, Short stories & nursery rhymes); only the passages differ.
///
/// Flow per passage: idle → reading ⇄ paused → passage done → Next.
/// Tapping any word opens the pronunciation sheet (and pauses reading first).
/// After the last passage the score is saved and the shared completion screen opens.
/// The screen's states are listed in `SentencesPracticePhase`.
@Observable
@MainActor
final class SentencesPracticeViewModel {
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
    private var correctWords = 0
    private var totalWords = 0
    private var task: Task<Void, Never>?

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
        case .passageDone: "Great reading!"
        case .interrupted: "The microphone stopped. Tap to keep reading."
        case .micFailed(.noMicrophone): "No microphone found. Connect one, or try on an iPhone."
        case .micFailed(.recognizerUnavailable): "Speech recognition isn't available right now. Tap to try again."
        case .micFailed(.audioFailed): "The microphone didn't start. Tap to try again."
        case .micDenied: "Allow the microphone and speech access to read aloud."
        case .finished: nil
        }
    }

    var showsMicrophone: Bool {
        switch phase {
        case .passageDone, .micDenied, .finished: false
        default: true
        }
    }

    var isReading: Bool { phase == .reading }

    var isLastPassage: Bool { passageIndex >= passages.count - 1 }

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
        guard let passage = currentPassage, !tracker.isFinished else { return }
        task?.cancel()
        voice.stop()
        task = Task {
            guard await reader.requestPermission() else {
                phase = .micDenied
                return
            }
            guard !Task.isCancelled else { return }
            tracker.beginSession()
            let failure = reader.start(
                expecting: passage.text(from: tracker.position),
                onHeard: { [weak self] heard in self?.didHear(heard) },
                onStopped: { [weak self] in self?.didStopListening() }
            )
            phase = failure.map { SentencesPracticePhase.micFailed($0) } ?? .reading
        }
    }

    func pause() {
        guard phase == .reading else { return }
        reader.stop()
        phase = .paused
    }

    private func didHear(_ heard: String) {
        guard phase == .reading else { return }
        tracker.update(heard: heard)
        readCount = tracker.position
        missedWords = tracker.skipped
        if tracker.isFinished { finishPassage() }
    }

    private func didStopListening() {
        guard phase == .reading else { return }
        phase = .interrupted
    }

    private func finishPassage() {
        reader.stop()
        correctWords += tracker.correctCount
        totalWords += tracker.words.filter { !$0.isEmpty }.count
        phase = .passageDone
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

    func didTapNext() {
        guard phase == .passageDone else { return }
        if isLastPassage {
            finish()
        } else {
            passageIndex += 1
            tracker = ReadingTracker(words: words.map(\.spoken))
            readCount = tracker.position
            missedWords = []
            phase = .idle
        }
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
        if phase == .reading { phase = .paused }
    }

    // MARK: - Private

    private var currentPassage: ReadingPassage? {
        passages.indices.contains(passageIndex) ? passages[passageIndex] : nil
    }

    /// Saves the score (words read right out of all words) and opens the completion screen.
    private func finish() {
        let outcome = progress.finish(exerciseId: exerciseId, correct: correctWords, total: max(totalWords, 1))
        phase = .finished(outcome)
        router.go(.completion(exerciseId: exerciseId, outcome: outcome))
    }
}
