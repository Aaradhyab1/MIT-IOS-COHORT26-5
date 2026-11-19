import Foundation
import Observation

/// Completion screen shown at the end of every exercise, in both tracks.
///
/// An exercise opens it with `router.go(.completion(exerciseId:outcome:))` after
/// saving its score. The pictures come from `CompletionArtwork` for the exercise's level.
@Observable
@MainActor
final class CompletionViewModel {
    let outcome: Outcome
    /// Characters peeking over the card. Empty shows `symbol` instead.
    let friendImages: [String]

    private let exerciseId: String
    private let router: AppRouter

    init(exerciseId: String, outcome: Outcome, content: any ContentRepository, router: AppRouter) {
        self.exerciseId = exerciseId
        self.outcome = outcome
        self.router = router
        let levelId = content.exercise(id: exerciseId)?.levelId
        self.friendImages = CompletionArtwork.images(levelId: levelId, outcome: outcome)
    }

    var title: String {
        switch outcome {
        case .greatJob: return "Great Job!"
        case .almostThere: return "Almost There!"
        case .keepPractising: return "Exercise Completed"
        }
    }

    var message: String {
        switch outcome {
        case .greatJob: return "You did really well.\nKeep it up!"         // TODO(copy)
        case .almostThere: return "You’re doing great!\nKeep going!"
        case .keepPractising: return "You're getting better! Keep it up!"
        }
    }

    /// Shown when there are no friend images, until the level's art is added.
    var symbol: String { "checkmark.seal.fill" }

    var primaryTitle: String {
        outcome == .keepPractising ? "Back to Home" : "Continue"
    }

    var showsTryAgain: Bool {
        outcome == .almostThere     // Figma: only Almost There offers Try Again
    }

    func primaryTapped() {
        router.popToRoot()
    }

    /// Leave the completion screen and the finished exercise, then start it again.
    func tryAgainTapped() {
        router.back()
        router.back()
        router.go(.exercise(exerciseId: exerciseId))
    }
}
