import Foundation
import Observation

/// Identification game: hear a sound, pick it from four pictures.
///
/// Placeholder logic: back opens the shared leave overlay, and "Finish (demo)" saves a
/// score and opens the shared completion screen. Replace it with the real game rounds,
/// keeping those two endings.
@Observable
@MainActor
final class PictureChoiceViewModel {
    let title: String

    private let exerciseId: String
    private let progress: any ProgressRepository
    private let router: AppRouter

    init(
        exerciseId: String,
        content: any ContentRepository,
        progress: any ProgressRepository,
        router: AppRouter
    ) {
        self.exerciseId = exerciseId
        self.title = content.exercise(id: exerciseId)?.title ?? "Exercise"
        self.progress = progress
        self.router = router
    }

    /// Back button: asks "Leave this practice?" using the shared overlay.
    func didTapBack() {
        router.presentLeavePractice()
    }

    /// Temporary shortcut until the game is built.
    func didTapFinishDemo() {
        let outcome = progress.finish(exerciseId: exerciseId, correct: 1, total: 1)
        router.go(.completion(exerciseId: exerciseId, outcome: outcome))
    }
}
