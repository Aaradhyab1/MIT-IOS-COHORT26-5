import Foundation

/// ViewModel factories for Level 2 — Differentiation.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeOddOneOutViewModel(exerciseId: String) -> OddOneOutViewModel {
        OddOneOutViewModel(exerciseId: exerciseId, content: content, progress: progress, router: router)
    }
}
