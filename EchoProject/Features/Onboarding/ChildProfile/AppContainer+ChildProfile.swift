import Foundation

/// ViewModel factories for the child profile step.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeChildProfileViewModel() -> ChildProfileViewModel {
        ChildProfileViewModel(router: router, profile: profile)
    }
}
