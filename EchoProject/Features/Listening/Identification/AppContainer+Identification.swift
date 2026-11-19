import Foundation

/// ViewModel factories for Level 3 — Identification.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makePictureChoiceViewModel(exerciseId: String) -> PictureChoiceViewModel {
        PictureChoiceViewModel(exerciseId: exerciseId, content: content, progress: progress, router: router)
    }
}
