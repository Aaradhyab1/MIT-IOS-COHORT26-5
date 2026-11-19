import Foundation

/// ViewModel factories for the Listening home tab.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeListeningHomeViewModel() -> ListeningHomeViewModel {
        ListeningHomeViewModel(content: content, router: router)
    }
}
