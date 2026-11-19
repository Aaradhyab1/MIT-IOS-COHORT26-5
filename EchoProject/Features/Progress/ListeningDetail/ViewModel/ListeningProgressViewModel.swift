import Foundation
import Observation

/// Listening progress per level.
///
/// Placeholder logic: only the navigation is in place. Add this screen's state here.
@Observable
@MainActor
final class ListeningProgressViewModel {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }
}
