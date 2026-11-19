import Foundation

/// ViewModel factories for Speaking progress detail.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeSpeakingProgressViewModel() -> SpeakingProgressViewModel {
        SpeakingProgressViewModel(router: router)
    }
}
