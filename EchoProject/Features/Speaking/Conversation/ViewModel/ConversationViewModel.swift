import Foundation
import Observation

/// Conversation role-play at the ice cream shop, flowing like a real chat.
///
/// The shopkeeper asks (out loud) → the child answers → the shopkeeper confirms
/// ("Chocolate, great choice!") and goes straight on to the next question.
/// An answer that is not one of the choices → "Sorry, you can only choose …" and the
/// same question again. After the last answer: "Here you go! Your ice cream is ready."
/// with a picture of the ice cream built from the child's choices.
/// The screen's states are listed in `ConversationPhase`.
@Observable
@MainActor
final class ConversationViewModel {
    /// Below this loudness (0 ... 1) the recording counts as silence.
    static let voiceThreshold = 0.01
    /// Recording stops on its own after this long.
    static let maxRecordingSeconds = 6
    /// Once one of the choices is heard, recording stops this long after.
    static let stopDelayAfterAnswer: Duration = .seconds(1)

    let title: String

    private(set) var phase: ConversationPhase = .intro
    private(set) var turnIndex = 0
    /// What the shopkeeper's speech bubble says right now.
    private(set) var shopkeeperLine = ""
    /// The child's last valid answer, shown in their own bubble.
    private(set) var childLine: String?
    /// Short message under the controls, e.g. "I didn't hear that."
    private(set) var notice: String?
    private(set) var heardText = ""
    /// One choice per finished turn, in order: [Chocolate, Cone, Sprinkles].
    private(set) var order: [ConversationChoice] = []

    private let exerciseId: String
    private let turns: [ConversationTurn]
    private let recording: any RecordingService
    private let speech: any SpeechRecognitionService
    private let voice: any SpeechSynthesisService
    private let progress: any ProgressRepository
    private let router: AppRouter

    /// True after an answer that was not one of the choices on this turn.
    private var hadRetry = false
    /// Turns answered with a valid choice on the first try; used for the score.
    private var firstTryCount = 0
    private var task: Task<Void, Never>?
    /// Waits the second before stopping, once an answer was heard.
    private var autoStopTask: Task<Void, Never>?

    init(
        exerciseId: String,
        content: any ContentRepository,
        recording: any RecordingService,
        speech: any SpeechRecognitionService,
        voice: any SpeechSynthesisService,
        progress: any ProgressRepository,
        router: AppRouter
    ) {
        let exercise = content.exercise(id: exerciseId)
        self.exerciseId = exerciseId
        self.title = exercise?.title ?? "Conversation"
        self.turns = (exercise?.items ?? []).map(ConversationTurn.init)
        self.recording = recording
        self.speech = speech
        self.voice = voice
        self.progress = progress
        self.router = router
    }

    // MARK: - Current turn

    private var currentTurn: ConversationTurn? {
        turns.indices.contains(turnIndex) ? turns[turnIndex] : nil
    }

    var turnCount: Int { turns.count }

    /// "Turn 1 of 3"
    var turnText: String { "Turn \(min(turnIndex, turns.count - 1) + 1) of \(turns.count)" }

    var choices: [ConversationChoice] { currentTurn?.choices ?? [] }

    var prompt: String { currentTurn?.prompt ?? "" }

    /// Picture slot for the shopkeeper.
    var shopkeeperImageName: String? { currentTurn?.imageName ?? turns.first?.imageName }

    /// Picture slot for the finished ice cream, named after the choices:
    /// "img_icecream_chocolate_cone_sprinkles".
    var iceCreamImageName: String {
        (["img_icecream"] + order.map { $0.label.lowercased() }).joined(separator: "_")
    }

    /// "chocolate, cone and sprinkles"
    var orderSummary: String {
        let words = order.map { $0.label.lowercased() }
        guard let last = words.last else { return "" }
        let rest = words.dropLast()
        return rest.isEmpty ? last : rest.joined(separator: ", ") + " and " + last
    }

    // MARK: - Starting

    /// "Start Conversation": makes sure speech checking works, then the first question.
    func didTapStart() {
        guard phase == .intro else { return }
        phase = .preparing
        task?.cancel()
        task = Task {
            guard await speech.prepare() else {
                phase = .unavailable
                return
            }
            askCurrentQuestion(after: nil)
        }
    }

    /// The shopkeeper says `lead` (a confirmation of the last answer) and the current
    /// question in one go, then it is the child's turn.
    private func askCurrentQuestion(after lead: String?) {
        guard let currentTurn else { return }
        hadRetry = false
        notice = nil
        heardText = ""
        say([lead, currentTurn.question].compactMap { $0 }.joined(separator: " "), then: .yourTurn)
    }

    /// Shows `line` in the bubble, says it out loud, then moves to `next`.
    private func say(_ line: String, then next: ConversationPhase) {
        task?.cancel()
        voice.stop()
        shopkeeperLine = line
        phase = .shopkeeperTalking
        task = Task {
            await voice.speak(line, slowly: false)
            guard !Task.isCancelled, phase == .shopkeeperTalking else { return }
            if next == .finished { finish() } else { phase = next }
        }
    }

    /// Speaker button on the bubble: hear the shopkeeper again.
    func didTapHearAgain() {
        guard phase == .yourTurn else { return }
        notice = nil
        say(shopkeeperLine, then: .yourTurn)
    }

    // MARK: - Recording

    /// "Tap to speak" or the microphone button.
    func didTapSpeak() {
        guard phase == .yourTurn else { return }
        task?.cancel()
        voice.stop()
        notice = nil
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
                notice = "The microphone didn't start. Please try again."
                phase = .yourTurn
                return
            }
            phase = .recording
            speech.startListening(expecting: choices.map { $0.label.lowercased() }) { [weak self] text in
                self?.heardWhileRecording(text)
            }

            try? await Task.sleep(for: .seconds(Self.maxRecordingSeconds))
            if !Task.isCancelled { await finishRecording() }
        }
    }

    /// Live captions: as soon as one of the choices is heard, stop 1 second later.
    private func heardWhileRecording(_ text: String) {
        guard phase == .recording, autoStopTask == nil,
              ChoiceMatcher.choice(in: text, from: choices) != nil else { return }
        autoStopTask = Task {
            try? await Task.sleep(for: Self.stopDelayAfterAnswer)
            guard !Task.isCancelled, phase == .recording else { return }
            didTapStop()
        }
    }

    /// The red stop button (also used by the automatic stop).
    func didTapStop() {
        autoStopTask?.cancel()
        autoStopTask = nil
        task?.cancel()
        task = Task { await finishRecording() }
    }

    private func finishRecording() async {
        guard phase == .recording else { return }
        speech.stopListening()
        autoStopTask?.cancel()
        autoStopTask = nil
        let result = recording.stopRecording()

        guard result.peakLevel >= Self.voiceThreshold else {
            notice = "I didn't hear that. Tap to speak and try again."
            phase = .yourTurn
            return
        }

        phase = .checking
        heardText = await speech.transcribe(result, expecting: choices.map { $0.label.lowercased() })

        guard let turn = currentTurn, let choice = ChoiceMatcher.choice(in: heardText, from: choices) else {
            // Not one of the choices (or nothing understood): the shopkeeper asks again.
            hadRetry = true
            notice = heardText.isEmpty ? nil : "We heard: “\(heardText)”"
            say(currentTurn?.retryLine ?? "", then: .yourTurn)
            return
        }

        // A valid answer: the shopkeeper confirms it and carries on.
        childLine = choice.label
        order.append(choice)
        if !hadRetry { firstTryCount += 1 }
        let confirmation = turn.confirmation(for: choice)
        turnIndex += 1
        if currentTurn == nil {
            say(confirmation + " Here you go! Your ice cream is ready.", then: .finished)
        } else {
            askCurrentQuestion(after: confirmation)
        }
    }

    // MARK: - Ending

    /// "Back to home" on the ice cream screen.
    func didTapDone() {
        stopAll()
        router.popToRoot()
    }

    /// Back button. During the conversation it opens the shared "Leave this practice?"
    /// overlay; on the intro, the ice cream screen, or when speech checking is
    /// unavailable, it simply goes back.
    func didTapBack() {
        switch phase {
        case .intro, .finished, .unavailable, .micDenied:
            stopAll()
            router.back()
        default:
            router.presentLeavePractice()
        }
    }

    /// Stops the voice and any recording. The screen calls it when it disappears,
    /// including after "Leave" on the shared overlay.
    func stopAll() {
        task?.cancel()
        autoStopTask?.cancel()
        autoStopTask = nil
        speech.stopListening()
        voice.stop()
        if recording.isRecording { _ = recording.stopRecording() }
    }

    // MARK: - Private

    /// Saves the score (turns answered on the first try) and shows the ice cream.
    private func finish() {
        _ = progress.finish(exerciseId: exerciseId, correct: firstTryCount, total: turns.count)
        phase = .finished
    }
}
