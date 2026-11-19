import Foundation

/// ViewModel factories for Level 1 — Detection.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeListenAndRespondViewModel(exerciseId: String) -> ListenAndRespondViewModel {
        ListenAndRespondViewModel(
            exerciseId: exerciseId,
            content: content,
            audio: audio,
            progress: progress,
            router: router
        )
    }
}
