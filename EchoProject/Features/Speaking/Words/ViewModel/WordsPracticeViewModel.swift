import Foundation
import Observation

/// Words: hear the word, say it once, and the app checks it with speech recognition.
///
/// Flow per word: listen → record → checking → result. From the result the child can
/// get pronunciation help (each sound, then the word, said slowly) and try again.
/// The screen's states are listed in `WordsPracticePhase`.
@Observable
@MainActor
final class WordsPracticeViewModel {
    /// Below this loudness (0 ... 1) the recording counts as silence.
    static let voiceThreshold = 0.01
    /// Recording stops on its own after this long.
    static let maxRecordingSeconds = 5
    /// How many words one practice uses. They are picked at random from the
    /// exercise's word list, so each practice shows a different mix.
    static let wordsPerSession = 5

    private(set) var phase: WordsPracticePhase = .preparing
    private(set) var itemIndex = 0
    private(set) var heardText = ""
    private(set) var highlightedSoundIndex: Int?
    private(set) var isPlayingRecording = false

    private let exerciseId: String
    private let items: [WordPracticeItem]
    private let recording: any RecordingService
    private let speech: any SpeechRecognitionService
    private let voice: any SpeechSynthesisService
    private let progress: any ProgressRepository
    private let router: AppRouter

    private var lastRecording: RecordingResult?
    private var correctItemIds: Set<String> = []
    private var task: Task<Void, Never>?

    init(
        exerciseId: String,
        content: any ContentRepository,
        recording: any RecordingService,
        speech: any SpeechRecognitionService,
        voice: any SpeechSynthesisService,
        progress: any ProgressRepository,
        router: AppRouter
    ) {
        self.exerciseId = exerciseId
        let allWords = (content.exercise(id: exerciseId)?.items ?? []).map(WordPracticeItem.init)
        self.items = Array(allWords.shuffled().prefix(Self.wordsPerSession))
        self.recording = recording
        self.speech = speech
        self.voice = voice
        self.progress = progress
        self.router = router
    }

    // MARK: - Current word

    private var currentItem: WordPracticeItem? {
        items.indices.contains(itemIndex) ? items[itemIndex] : nil
    }

    var word: String { currentItem?.word ?? "" }

    var positionText: String { "Word \(itemIndex + 1)" }

    var soundChips: [String] { currentItem?.soundChips ?? [] }

    var hint: String { currentItem?.hint ?? "" }

    var isLastItem: Bool { itemIndex >= items.count - 1 }

    /// Number of words in this practice.
    var wordCount: Int { items.count }

    private var acceptedAnswers: [String] { currentItem?.acceptedAnswers ?? [] }

    private var parts: [WordPart] { currentItem?.parts ?? [] }

    // MARK: - Screen text

    var instruction: String {
        switch phase {
        case .preparing: "Getting ready…"
        case .listen: "Tap play to hear the word."
        case .playing: "Listening…"
        case .listened: "Press Record when you are ready."
        case .readyToRecord: "Tap the mic, then say the word."
        case .recording: "Speak now. Tap stop when you're done."
        case .checking: "Checking…"
        case .result(.correct): "Great job! You said it beautifully."
        case .result: "Almost there! Let's practise together."
        case .help, .guidedHelp: "Follow each sound, then say the word."
        case .noVoice: "I didn't hear that. Let's try again."
        case .notUnderstood: "I couldn't catch the word. Listen to your recording, then try again."
        case .recordingFailed: "The microphone didn't start. Please try again."
        case .micDenied: "Allow microphone access to practise."
        case .unavailable: "Speech checking isn't available on this iPhone yet."
        case .finished: ""
        }
    }

    /// Shown under a result, so the parent can see what the app understood.
    var heardDescription: String? {
        heardText.isEmpty ? nil : "We heard: “\(heardText)”"
    }

    var recordingDuration: String {
        let seconds = Int((lastRecording?.duration ?? 0).rounded())
        return String(format: "0:%02d", seconds)
    }

    // MARK: - Lifecycle

    /// Downloads the speech model the first time (needs internet once).
    func onAppear() async {
        guard phase == .preparing else { return }
        phase = await speech.prepare() ? .listen : .unavailable
    }

    // MARK: - Listening

    func didTapPlay() {
        phase = .playing
        task?.cancel()
        task = Task {
            await voice.speak(word, slowly: false)
            if phase == .playing { phase = .listened }
        }
    }

    func didTapPause() {
        task?.cancel()
        voice.stop()
        phase = .listened
    }

    /// "Record" after listening: starts recording straight away, with no extra mic screen.
    func didTapRecord() {
        didTapMicrophone()
    }

    // MARK: - Recording

    func didTapMicrophone() {
        task?.cancel()
        voice.stop()
        task = Task {
            let micAllowed = await recording.requestPermission()
            let speechAllowed = await speech.requestPermission()
            guard micAllowed, speechAllowed else {
                phase = .micDenied
                return
            }
            heardText = ""
            recording.startRecording()
            guard recording.isRecording else {
                phase = .recordingFailed
                return
            }
            phase = .recording

            try? await Task.sleep(for: .seconds(Self.maxRecordingSeconds))
            if !Task.isCancelled { await finishRecording() }
        }
    }

    func didTapStop() {
        task?.cancel()
        task = Task { await finishRecording() }
    }

    private func finishRecording() async {
        guard phase == .recording else { return }
        let result = recording.stopRecording()
        lastRecording = result

        guard result.peakLevel >= Self.voiceThreshold else {
            phase = .noVoice
            return
        }

        phase = .checking
        heardText = await speech.transcribe(result, expecting: acceptedAnswers)
        guard !PronunciationScorer.normalized(heardText).isEmpty else {
            phase = .notUnderstood
            return
        }

        let verdict = PronunciationScorer.judge(heard: heardText, accepted: acceptedAnswers)
        if verdict == .correct { markCurrentWordCorrect() }
        phase = .result(verdict)
    }

    func didTapPlayRecording() {
        guard let lastRecording, !isPlayingRecording else { return }
        isPlayingRecording = true
        Task {
            await recording.playRecording(lastRecording)
            isPlayingRecording = false
        }
    }

    // MARK: - Pronunciation help

    func didTapHearPronunciation() {
        playGuidedHelp()
    }

    /// Says the word part by part ("s" … "un") while highlighting each chip,
    /// then the whole word, slowly.
    func playGuidedHelp() {
        task?.cancel()
        voice.stop()
        phase = .guidedHelp
        let wordParts = self.parts
        task = Task {
            for (index, part) in wordParts.enumerated() {
                guard !Task.isCancelled else { return }
                highlightedSoundIndex = index
                await say(part)
                try? await Task.sleep(for: .milliseconds(250))   // short gap between parts
            }
            highlightedSoundIndex = nil
            guard !Task.isCancelled else { return }
            await voice.speak(word, slowly: true)
            if phase == .guidedHelp { phase = .help }
        }
    }

    /// Tapping a chip says just that part.
    func didTapSound(at index: Int) {
        guard parts.indices.contains(index) else { return }
        task?.cancel()
        voice.stop()
        highlightedSoundIndex = index
        let part = parts[index]
        task = Task {
            await say(part)
            highlightedSoundIndex = nil
        }
    }

    /// Says one part as it sounds, using its IPA when the content provides one.
    private func say(_ part: WordPart) async {
        if let ipa = part.ipa {
            await voice.speakSound(part.chip.lowercased(), ipa: ipa)
        } else {
            await voice.speak(part.chip.lowercased(), slowly: true)
        }
    }

    func didTapTryAgain() {
        task?.cancel()
        voice.stop()
        highlightedSoundIndex = nil
        heardText = ""
        phase = .readyToRecord
    }

    // MARK: - Moving on

    func didTapNext() {
        task?.cancel()
        voice.stop()
        if isLastItem {
            finish()
        } else {
            itemIndex += 1
            heardText = ""
            lastRecording = nil
            phase = .listen
        }
    }

    /// Back button. During practice it opens the shared "Leave this practice?" overlay;
    /// where nothing is in progress it simply goes back.
    func didTapBack() {
        switch phase {
        case .finished, .preparing, .unavailable:
            didTapGoBack()
        default:
            router.presentLeavePractice()
        }
    }

    /// "Go back" when speech checking is unavailable.
    func didTapGoBack() {
        stopAll()
        router.back()
    }

    /// Stops the voice and any recording. The screen calls it when it disappears,
    /// including after "Leave" on the shared overlay.
    func stopAll() {
        task?.cancel()
        voice.stop()
        if recording.isRecording { _ = recording.stopRecording() }
    }

    // MARK: - Private

    private func markCurrentWordCorrect() {
        if let id = currentItem?.id { correctItemIds.insert(id) }
    }

    /// Saves the score and opens the shared completion screen.
    private func finish() {
        let outcome = progress.finish(exerciseId: exerciseId, correct: correctItemIds.count, total: items.count)
        phase = .finished(outcome)
        router.go(.completion(exerciseId: exerciseId, outcome: outcome))
    }
}
