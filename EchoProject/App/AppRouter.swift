import SwiftUI
import Observation

enum AppTab: Hashable {
    case listening
    case speaking
    case progress
}

/// Single source of truth for navigation.
///
/// ViewModels call `router.go(.exercise(exerciseId: id))`, `router.back()` etc.
/// Views never push or build destinations themselves.
@Observable
@MainActor
final class AppRouter {
    enum Overlay: String, Identifiable {
        case leavePractice      // "Leave this practice?"
        var id: String { rawValue }
    }

    var isOnboardingComplete: Bool
    var selectedTab: AppTab = .listening
    var overlay: Overlay?

    var onboardingPath = NavigationPath()
    var listeningPath = NavigationPath()
    var speakingPath = NavigationPath()
    var progressPath = NavigationPath()

    init(isOnboardingComplete: Bool = false) {
        self.isOnboardingComplete = isOnboardingComplete
    }

    // MARK: - Navigation

    /// Pushes onto onboarding until it is finished, then onto the current tab.
    func go(_ route: Route) {
        updateCurrentPath { $0.append(route) }
    }

    func back() {
        updateCurrentPath { path in
            if !path.isEmpty { path.removeLast() }
        }
    }

    func popToRoot() {
        updateCurrentPath { $0 = NavigationPath() }
    }

    func select(_ tab: AppTab) {
        selectedTab = tab
    }

    func finishOnboarding() {
        onboardingPath = NavigationPath()
        selectedTab = .listening
        isOnboardingComplete = true
    }

    // MARK: - Overlays

    func presentLeavePractice() {
        overlay = .leavePractice
    }

    func dismissOverlay() {
        overlay = nil
    }

    // MARK: - Private

    private func updateCurrentPath(_ change: (inout NavigationPath) -> Void) {
        guard isOnboardingComplete else {
            change(&onboardingPath)
            return
        }
        switch selectedTab {
        case .listening: change(&listeningPath)
        case .speaking: change(&speakingPath)
        case .progress: change(&progressPath)
        }
    }
}
