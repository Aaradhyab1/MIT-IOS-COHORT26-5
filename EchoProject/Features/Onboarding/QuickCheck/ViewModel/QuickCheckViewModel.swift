import Foundation
import Observation

/// The 8-question Quick Check: Often / Sometimes / Never.
///
/// Placeholder logic: only the navigation is in place. Add this screen's state here.
@Observable
@MainActor
final class QuickCheckViewModel {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }

    /// Temporary shortcut until the questions are built.
    func didTapSeeResult() {
        router.go(.quickCheckResult)
    }
}
