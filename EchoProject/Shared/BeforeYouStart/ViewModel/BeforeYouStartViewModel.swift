import Foundation
import Observation

/// The intro screen shown before every exercise: what the game is, how to play,
/// a tip for the parent, and Start.
///
/// Everything on screen is worked out once in `init` from the exercise, its level
/// and its game template, so the View only displays ready-made text.
@Observable
@MainActor
final class BeforeYouStartViewModel {
    /// "LEVEL 3 · IDENTIFICATION"
    let eyebrow: String
    let title: String
    let summary: String
    /// Asset name of the round artwork at the top.
    let illustration: String
    /// "5 min", "10 sounds", and "Headphones on" for Listening exercises.
    let metaPills: [String]
    let steps: [ExerciseInstructions.Step]
    let tip: String
    /// False when the exercise has no clip to preview; the button is then hidden.
    let canPlayExample: Bool

    /// True while the example clip plays; the button shows "Playing…" and is disabled.
    private(set) var isPlayingExample = false

    private let exerciseId: String
    private let exampleClip: String?
    private let audio: any AudioPlaybackService
    private let router: AppRouter

    init(
        exerciseId: String,
        content: any ContentRepository,
        audio: any AudioPlaybackService,
        router: AppRouter
    ) {
        self.exerciseId = exerciseId
        self.audio = audio
        self.router = router

        guard let exercise = content.exercise(id: exerciseId) else {
            eyebrow = ""
            title = "Exercise not found"
            summary = ""
            illustration = ""
            metaPills = []
            steps = []
            tip = ""
            exampleClip = nil
            canPlayExample = false
            return
        }

        let instructions = ExerciseInstructions.forType(exercise.type)

        if let level = content.level(id: exercise.levelId) {
            eyebrow = "LEVEL \(level.order) · \(level.title.uppercased())"
        } else {
            eyebrow = ""
        }
        title = exercise.title
        summary = exercise.summary
        illustration = exercise.illustration

        var pills = [
            "\(exercise.durationMinutes) min",
            "\(exercise.repetitions) \(instructions.itemWord)"
        ]
        if exercise.type.track == .listening {
            pills.append("Headphones on")
        }
        metaPills = pills

        steps = instructions.steps
        tip = instructions.tip

        // The first item's clip, or its first option's clip (Odd one out keeps sounds on options).
        let firstItem = exercise.items.first
        let clip = firstItem?.audio ?? firstItem?.options?.first?.audio
        exampleClip = clip
        canPlayExample = clip != nil
    }

    // MARK: - Actions

    func start() {
        stopExample()
        router.go(.exercise(exerciseId: exerciseId))
    }

    /// Plays one example clip. Waits until the clip ends.
    func playExample() async {
        guard let exampleClip, !isPlayingExample else { return }
        isPlayingExample = true
        await audio.play(exampleClip)
        isPlayingExample = false
    }

    /// Called when the screen goes away, so the example does not keep playing.
    func stopExample() {
        guard isPlayingExample else { return }
        audio.stop()
        isPlayingExample = false
    }
}
