import Foundation

/// ViewModel factories for the Progress Overview screen.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeProgressOverviewViewModel() -> ProgressOverviewViewModel {
        ProgressOverviewViewModel(service: progressReports, router: router)
    }
}
