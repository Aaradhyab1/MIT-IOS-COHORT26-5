import Foundation
import Observation

/// Result reveal and "Great start!" with the recommended level.
///
/// Placeholder logic: only the navigation is in place. Add this screen's state here.
@Observable
@MainActor
final class QuickCheckResultViewModel {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }

    func didTapGoHome() {
        router.finishOnboarding()
    }
}
