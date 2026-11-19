import Foundation
import Observation

/// Choose the Quick Check or pick a starting level (custom level overlay).
///
/// Placeholder logic: only the navigation is in place. Add this screen's state here.
@Observable
@MainActor
final class ChoosePathViewModel {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }

    func didTapQuickCheck() {
        router.go(.quickCheck)
    }

    /// TODO: Show the custom level overlay; for now it goes straight to Home.
    func didTapChooseLevel() {
        router.finishOnboarding()
    }
}
