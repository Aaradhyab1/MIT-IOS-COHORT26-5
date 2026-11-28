import Foundation
import Observation

/// The intro screen shown before every exercise: what the game is, how to play, and Start.
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
    /// "3 min" and "5 sounds", worked out from the exercise's content (`ExercisePlan`).
    let metaPills: [String]
    let steps: [ExerciseInstructions.Step]

    private let exerciseId: String
    private let router: AppRouter

    init(exerciseId: String, content: any ContentRepository, router: AppRouter) {
        self.exerciseId = exerciseId
        self.router = router

        guard let exercise = content.exercise(id: exerciseId) else {
            eyebrow = ""
            title = "Exercise not found"
            summary = ""
            illustration = ""
            metaPills = []
            steps = []
            return
        }

        if let level = content.level(id: exercise.levelId) {
            eyebrow = "LEVEL \(level.order) · \(level.title.uppercased())"
        } else {
            eyebrow = ""
        }
        title = exercise.title
        summary = exercise.summary
        illustration = exercise.illustration

        let plan = ExercisePlan.played(exercise)
        metaPills = [plan.minutesText, plan.roundsText]
        steps = ExerciseInstructions.forExercise(exercise).steps
    }

    // MARK: - Actions

    func start() {
        router.go(.exercise(exerciseId: exerciseId))
    }
}
