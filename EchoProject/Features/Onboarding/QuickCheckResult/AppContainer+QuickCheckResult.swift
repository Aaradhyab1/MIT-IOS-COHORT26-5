import Foundation

/// ViewModel factories for the Quick Check result.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeQuickCheckResultViewModel() -> QuickCheckResultViewModel {
        QuickCheckResultViewModel(router: router)
    }
}
