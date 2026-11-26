import Foundation
import Observation

/// Detection game ("Did you hear it?"), used by every Detection exercise.
///
/// Each item in the exercise is one round:
///   ready ("Tap Play") → playing → asking ("Did you hear it?") → reveal → next round.
/// An item with no audio is a silent round, where "I didn't hear it" is the right answer.
/// After the last round the score is saved and the completion screen opens.
@Observable
@MainActor
final class ListenAndRespondViewModel {
    enum Phase {
        case ready
        case playing
        case asking
        case reveal
    }

    private(set) var phase: Phase = .ready
    private(set) var roundIndex = 0
    private(set) var lastAnswerCorrect = false
    private var correctCount = 0

    /// Goes up by one every time Play is tapped. A sound that finishes late
    /// (after Pause and Play again) sees a different number and is ignored.
    private var playbackId = 0

    private let exerciseId: String
    private let items: [ExerciseItem]
    private let audio: any AudioPlaybackService
    private let progress: any ProgressRepository
    private let router: AppRouter

    init(
        exerciseId: String,
        content: any ContentRepository,
        audio: any AudioPlaybackService,
        progress: any ProgressRepository,
        router: AppRouter
    ) {
        self.exerciseId = exerciseId
        self.items = content.exercise(id: exerciseId)?.items ?? []
        self.audio = audio
        self.progress = progress
        self.router = router
    }

    // MARK: - What the screen shows

    var title: String {
        switch phase {
        case .ready, .playing: return "Listen to the sound!"
        case .asking: return currentItem?.prompt ?? "Did you hear it?"
        case .reveal: return hasSound ? "Hello, \(soundName)!" : "Nothing was hiding!"   // TODO(copy)
        }
    }

    var subtitle: String? {
        phase == .reveal && hasSound ? "I was hiding behind the cloud." : nil
    }

    var bubbleTitle: String? {
        switch phase {
        case .ready: return roundIndex == 0 ? "An animal is hiding." : "Is something hiding?"
        case .playing: return "The animal is making a sound."
        case .asking: return nil
        case .reveal: return lastAnswerCorrect ? "Nice listening!" : "Almost there!"
        }
    }

    var bubbleDetail: String? {
        switch phase {
        case .ready: return roundIndex == 0 ? "Tap Play to hear the sound." : "Tap Play to hear it."
        case .reveal:
            if lastAnswerCorrect {
                return isLastRound ? "You heard both animals!" : "Let’s find another animal."
            }
            return isLastRound
                ? "That was the \(soundName). You’re learning with every try!"
                : "That was the \(soundName). Let’s try the next sound."
        default: return nil
        }
    }

    /// Picture that pops up on the cloud after the reveal (nil = empty cloud).
    var revealImage: String? {
        guard phase == .reveal, hasSound else { return nil }
        guard !lastAnswerCorrect else { return currentItem?.image }

        switch currentItem?.text?.lowercased() {
        case "cat": return "img_cat_worried"
        case "dog": return "img_dog_worried"
        default: return currentItem?.image
        }
    }

    /// True when the reveal picture already has its own cloud drawn in (img_bunny),
    /// so the screen must not draw the plain cloud behind it.
    var revealIncludesCloud: Bool {
        guard let image = revealImage else { return false }
        return Self.imagesWithOwnCloud.contains(image)
    }

    private static let imagesWithOwnCloud: Set<String> = ["img_bunny"]

    var roundText: String {
        "\(roundIndex + 1) of \(items.count)"
    }

    // MARK: - Actions

    func playTapped() {
        if phase == .ready {
            phase = .playing
            playbackId += 1
            let id = playbackId
            Task { await playCurrentSound(id: id) }
        } else if phase == .playing {
            audio.stop()
            phase = .ready
        }
    }

    func answer(heardIt: Bool) {
        guard phase == .asking else { return }
        lastAnswerCorrect = (heardIt == hasSound)
        if lastAnswerCorrect { correctCount += 1 }
        phase = .reveal
    }

    func nextTapped() {
        guard phase == .reveal else { return }
        if isLastRound {
            let outcome = progress.finish(exerciseId: exerciseId, correct: correctCount, total: items.count)
            router.go(.completion(exerciseId: exerciseId, outcome: outcome))
        } else {
            roundIndex += 1
            phase = .ready
        }
    }

    func backTapped() {
        audio.stop()
        if phase == .playing { phase = .ready }
        router.presentLeavePractice()
    }

    func stopAll() {
        audio.stop()
    }

    // MARK: - Private

    private var currentItem: ExerciseItem? {
        items.indices.contains(roundIndex) ? items[roundIndex] : nil
    }

    private var hasSound: Bool { currentItem?.audio != nil }
    private var isLastRound: Bool { roundIndex >= items.count - 1 }

    /// "dog" for the image "img_dog". A `text` on the item takes priority.
    private var soundName: String {
        if let text = currentItem?.text { return text }
        return (currentItem?.image ?? "friend").replacingOccurrences(of: "img_", with: "")
    }

    private func playCurrentSound(id: Int) async {
        if let clip = currentItem?.audio {
            await audio.play(clip)
        } else {
            try? await Task.sleep(for: .seconds(2))     // silent round
        }
        // Only move on if this is still the latest Play tap and nobody pressed Pause.
        if id == playbackId && phase == .playing {
            phase = .asking
        }
    }
}
