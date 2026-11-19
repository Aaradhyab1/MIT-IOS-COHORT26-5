import Foundation

/// ViewModel factories for the shared "Leave this practice?" overlay.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeLeavePracticeViewModel() -> LeavePracticeViewModel {
        LeavePracticeViewModel(audio: audio, router: router)
    }
}
