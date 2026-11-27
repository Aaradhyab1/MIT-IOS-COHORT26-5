import Foundation
import Observation

/// Vowel sounds: meet a sound friend, then say its sound 3 times to move it home.
///
/// Flow per friend: meet → (play) → ready → listening → ready … → reachedGoal.
/// Each good try moves the friend one stop along the path and lights a star. A try that
/// doesn't count keeps the friend where it is and marks the next stop "Try this one again",
/// so nothing earned is ever taken away.
///
/// What counts as a good try (v1): the microphone heard a voice for long enough.
/// The app can measure that reliably; checking the vowel itself is a later step
/// (see `isGoodTry(_:)`).
@Observable
@MainActor
final class VowelPracticeViewModel {
    /// Good tries needed to bring a friend home.
    static let triesPerFriend = 3
    /// Below this loudness (0 ... 1) the recording counts as silence.
    static let voiceThreshold = 0.01
    /// A try shorter than this doesn't count.
    static let minimumVoiceSeconds: TimeInterval = 0.5
    /// One try stops recording on its own after this long.
    static let maxRecordingSeconds = 3

    let introSteps: [IntroStep] = [
        IntroStep(id: 0, icon: "icon_vowel_listen", title: "Listen"),
        IntroStep(id: 1, icon: "icon_vowel_mic", title: "Say it 3 times"),
        IntroStep(id: 2, icon: "img_vowel_plane_travel", title: "Help your friend get home"),
        IntroStep(id: 3, icon: "icon_vowel_stars", title: "Collect a star each time"),
    ]

    let friends: [SoundFriend]

    private(set) var phase: VowelPracticePhase = .intro
    private(set) var friendIndex = 0
    /// Good tries for the current friend (0 ... 3).
    private(set) var goodTries = 0

    private let exerciseId: String
    private let recording: any RecordingService
    private let voice: any SpeechSynthesisService
    private let progress: any ProgressRepository
    private let router: AppRouter
    private var totalTries = 0
    private var task: Task<Void, Never>?

    init(
        exerciseId: String,
        friends: [SoundFriend] = SoundFriend.vowelFriends,
        recording: any RecordingService,
        voice: any SpeechSynthesisService,
        progress: any ProgressRepository,
        router: AppRouter
    ) {
        self.exerciseId = exerciseId
        self.friends = friends
        self.recording = recording
        self.voice = voice
        self.progress = progress
        self.router = router
    }

    // MARK: - Current friend

    var friend: SoundFriend { friends[min(friendIndex, friends.count - 1)] }

    var isLastFriend: Bool { friendIndex >= friends.count - 1 }

    /// "Sound 1 of 3".
    var positionText: String { "Sound \(friendIndex + 1) of \(friends.count)" }

    /// The two stops before the goal (the goal itself is the third).
    var stops: [PathStop] {
        (0..<(Self.triesPerFriend - 1)).map { index in
            if index < goodTries { return .reached }
            if index == goodTries && phase == .tryAgain { return .tryAgain }
            return .waiting
        }
    }

    /// 0 at the start of the path, 1 at the goal.
    var pathProgress: Double { Double(goodTries) / Double(Self.triesPerFriend) }

    var isMicActive: Bool { phase == .listening }

    // MARK: - Screen text

    var title: String {
        switch phase {
        case .intro: "How it works"
        case .meet, .playing: "Meet \(friend.name)"
        case .ready, .listening: readyTitle
        case .tryAgain: "So close!"
        case .reachedGoal: "Hooray!"
        case .micDenied: "Let’s turn on the mic"
        case .finished: "You met\n\(friends.count) sound friends!"
        }
    }

    var subtitle: String {
        switch phase {
        case .intro: "Play with a sound friend for every sound."
        case .meet, .playing: "This is \(friend.name).\n\(friend.name) says “\(friend.vowel)”."
        case .ready: readySubtitle
        case .listening: "Echo is listening…\nsay “\(friend.vowel)”!"
        case .tryAgain: "Listen to Echo,\nthen try “\(friend.vowel)” once more."
        case .reachedGoal: friend.goalLine
        case .micDenied: "Ask a grown-up to allow the microphone in Settings."
        case .finished: "You practised \(vowelList).\nGreat listening and talking!"
        }
    }

    private var readyTitle: String {
        switch goodTries {
        case 0: "Your turn"
        case Self.triesPerFriend - 1: "Almost home!"
        default: "Nice one!"
        }
    }

    private var readySubtitle: String {
        switch goodTries {
        case 0: "Say “\(friend.vowel)” \(Self.triesPerFriend) times\nto help \(friend.name) reach \(friend.goalName)."
        case Self.triesPerFriend - 1: "Say “\(friend.vowel)” one more time!"
        default: "Say “\(friend.vowel)” again!"
        }
    }

    private var vowelList: String {
        let quoted = friends.map { "“\($0.vowel)”" }
        guard quoted.count > 1 else { return quoted.first ?? "" }
        return quoted.dropLast().joined(separator: ", ") + " and " + (quoted.last ?? "")
    }

    /// Button on the Hooray screen.
    var nextButtonTitle: String { isLastFriend ? "Finish" : "Next sound" }

    // MARK: - Intro and meet

    func didTapStart() {
        phase = .meet
    }

    func didTapPlay() {
        task?.cancel()
        phase = .playing
        task = Task {
            await voice.speakSound(friend.vowel, ipa: friend.ipa)
            if phase == .playing { phase = .ready }
        }
    }

    func didTapPause() {
        task?.cancel()
        voice.stop()
        phase = .meet
    }

    /// "Listen again" on the try-again screen.
    func didTapListenAgain() {
        task?.cancel()
        task = Task { await voice.speakSound(friend.vowel, ipa: friend.ipa) }
    }

    // MARK: - Trying

    /// Mic button: starts a try, or ends it early if one is running.
    func didTapMicrophone() {
        if phase == .listening {
            task?.cancel()
            finishTry()
            return
        }
        task?.cancel()
        voice.stop()
        task = Task {
            guard await recording.requestPermission() else {
                phase = .micDenied
                return
            }
            recording.startRecording()
            guard recording.isRecording else {
                phase = .tryAgain
                return
            }
            phase = .listening
            try? await Task.sleep(for: .seconds(Self.maxRecordingSeconds))
            if !Task.isCancelled { finishTry() }
        }
    }

    private func finishTry() {
        guard phase == .listening else { return }
        let result = recording.stopRecording()
        totalTries += 1
        guard isGoodTry(result) else {
            phase = .tryAgain
            return
        }
        goodTries += 1
        phase = goodTries >= Self.triesPerFriend ? .reachedGoal : .ready
    }

    /// v1 rule: a voice, long enough. Replace with a real vowel check when one is ready,
    /// keeping the same yes/no answer.
    private func isGoodTry(_ result: RecordingResult) -> Bool {
        result.peakLevel >= Self.voiceThreshold && result.duration >= Self.minimumVoiceSeconds
    }

    // MARK: - Moving on

    func didTapNext() {
        if isLastFriend {
            phase = .finished
        } else {
            friendIndex += 1
            goodTries = 0
            phase = .meet
        }
    }

    /// "Done" on the last screen: saves the result and returns to the Sounds list.
    func didTapDone() {
        let goodTotal = friends.count * Self.triesPerFriend
        _ = progress.finish(exerciseId: exerciseId, correct: goodTotal, total: max(totalTries, goodTotal))
        router.leavePractice()
    }

    /// Back button: asks "Leave this practice?" using the shared overlay.
    func didTapBack() {
        router.presentLeavePractice()
    }

    func onDisappear() {
        task?.cancel()
        voice.stop()
        if recording.isRecording { _ = recording.stopRecording() }
    }
}
