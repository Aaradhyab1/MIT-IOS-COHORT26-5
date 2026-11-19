import Foundation
import Observation

/// Progress tab: streak, sessions and learning paths.
///
/// Placeholder logic: only the navigation is in place. Add this screen's state here.
@Observable
@MainActor
final class ProgressOverviewViewModel {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }

    func didTapListening() {
        router.go(.listeningProgress)
    }

    func didTapSpeaking() {
        router.go(.speakingProgress)
    }
}
