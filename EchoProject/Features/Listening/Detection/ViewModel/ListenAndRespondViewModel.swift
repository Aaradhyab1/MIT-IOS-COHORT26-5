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
    let story: DetectionStory
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
        self.story = DetectionStory.forExercise(exerciseId)
        self.audio = audio
        self.progress = progress
        self.router = router
    }

    // MARK: - What the screen shows

    var title: String {
        switch phase {
        case .ready, .playing: return "Listen to the sound!"
        case .asking: return currentItem?.prompt ?? "Did you hear it?"
        case .reveal:
            guard hasSound else { return story.silentTitle }
            return currentReveal?.title ?? "Hello, \(soundName)!"
        }
    }

    var subtitle: String? {
        guard phase == .reveal else { return nil }
        guard hasSound else { return story.silentSubtitle }
        return currentReveal?.subtitle ?? "I was hiding behind the bush."
    }

    var bubbleTitle: String? {
        switch phase {
        case .ready: return roundIndex == 0 ? story.readyLine : story.nextReadyLine
        case .playing: return story.playingLine
        case .asking: return nil
        case .reveal: return lastAnswerCorrect ? "Nice listening!" : "Almost there!"
        }
    }

    var bubbleDetail: String? {
        switch phase {
        case .ready: return roundIndex == 0 ? "Tap Play to hear the sound." : "Tap Play to hear it."
        case .reveal:
            if lastAnswerCorrect {
                return isLastRound ? story.finishedLine : story.nextLine
            }
            let what = hasSound ? "That was the \(soundName)." : "There was no sound this time."
            return isLastRound
                ? "\(what) You’re learning with every try!"
                : "\(what) Let’s try the next sound."
        default: return nil
        }
    }

    /// Bush story: the animal that rises up from behind the bush after the answer.
    var revealImage: String? {
        guard story.hidingSpot == .bush, phase == .reveal, hasSound else { return nil }
        guard !lastAnswerCorrect else { return currentItem?.image }

        switch currentItem?.text?.lowercased() {
        case "cat": return "img_cat_worried"
        case "dog": return "img_dog_worried"
        default: return currentItem?.image
        }
    }

    /// House story: the plain house until the answer, then the doorbell ringing (silent rounds stay plain).
    var houseImage: String {
        guard phase == .reveal, hasSound, let image = currentReveal?.houseImage else { return "img_house" }
        return image
    }

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

    private var currentReveal: DetectionStory.Reveal? {
        currentItem?.audio.flatMap { story.reveals[$0] }
    }

    /// "dog" for the image "img_dog". A `text` on the item, then the story, take priority.
    private var soundName: String {
        if let text = currentItem?.text { return text }
        if let name = currentReveal?.name { return name }
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
