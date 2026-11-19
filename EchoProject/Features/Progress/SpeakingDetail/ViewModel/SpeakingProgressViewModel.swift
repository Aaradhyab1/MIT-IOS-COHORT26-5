import Foundation
import Observation

/// Speaking progress per category.
///
/// Placeholder logic: only the navigation is in place. Add this screen's state here.
@Observable
@MainActor
final class SpeakingProgressViewModel {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }
}
