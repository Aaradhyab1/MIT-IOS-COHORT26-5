import Foundation

/// ViewModel factories for the shared completion screen, shown at the end of every exercise.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeCompletionViewModel(exerciseId: String, outcome: Outcome) -> CompletionViewModel {
        CompletionViewModel(exerciseId: exerciseId, outcome: outcome, content: content, router: router)
    }
}
