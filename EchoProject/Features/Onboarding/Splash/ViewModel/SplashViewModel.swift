import Foundation
import Observation

/// Launch screen with the Echo elephant.
///
/// Placeholder logic: only the navigation is in place. Add this screen's state here.
@Observable
@MainActor
final class SplashViewModel {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }

    func didTapStart() {
        router.go(.childProfile)
    }

    /// Development shortcut while onboarding is being built. Remove before the review.
    func didTapSkipToHome() {
        router.finishOnboarding()
    }
}
