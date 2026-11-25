import Foundation
import Observation

/// "Where should we start?": take the Quick Check, or pick a starting level yourself.
///
/// Two overlays sit on top of the screen:
/// - Custom level: a dropdown of the 4 levels (closed → open → level selected → Continue).
/// - Level information: "The 4 levels", opened from the ⓘ button.
/// Continuing with a level saves it as the child's starting level and opens Home.
@Observable
@MainActor
final class ChoosePathViewModel {
    enum Overlay: Equatable {
        case customLevel
        case levelInfo
    }

    /// The 4 Listening levels, in order.
    let levels: [LevelGuide]

    private(set) var overlay: Overlay?
    private(set) var isLevelListOpen = false
    private(set) var selectedLevel: LevelGuide?

    private let router: AppRouter
    private let profile: any ProfileRepository

    init(router: AppRouter, content: any ContentRepository, profile: any ProfileRepository) {
        self.router = router
        self.profile = profile
        levels = content.levels(for: .listening).map(LevelGuide.init)
    }

    /// Continue shows once a level is picked and the list is closed.
    var canContinue: Bool {
        selectedLevel != nil && !isLevelListOpen
    }

    // MARK: - Main screen

    func didTapBack() {
        router.back()
    }

    func didTapQuickCheck() {
        router.go(.quickCheck)
    }

    func didTapChooseLevel() {
        selectedLevel = nil
        isLevelListOpen = false
        overlay = .customLevel
    }

    func didTapLevelInfo() {
        overlay = .levelInfo
    }

    // MARK: - Overlays

    /// ✕ button or a tap outside the panel.
    func didDismissOverlay() {
        overlay = nil
        isLevelListOpen = false
    }

    func didTapLevelField() {
        isLevelListOpen.toggle()
    }

    func didSelectLevel(_ level: LevelGuide) {
        selectedLevel = level
        isLevelListOpen = false
    }

    /// Saves the picked level as the starting level and opens Home.
    func didTapContinue() {
        guard let selectedLevel else { return }
        var child = profile.currentProfile() ?? ChildProfile()
        child.recommendedLevel = selectedLevel.number
        child.onboardingCompleted = true
        profile.save(child)
        overlay = nil
        router.finishOnboarding()
    }
}
