import Foundation
import Observation

/// Optional child profile: date of birth and device activation date.
///
/// Placeholder logic: only the navigation is in place. Add this screen's state here.
@Observable
@MainActor
final class ChildProfileViewModel {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }

    func didTapContinue() {
        router.go(.choosePath)
    }

    func didTapSkip() {
        router.go(.choosePath)
    }
}
