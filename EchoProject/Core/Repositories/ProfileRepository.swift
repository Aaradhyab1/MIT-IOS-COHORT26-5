import Foundation

/// The child's profile and Quick Check result.
/// This release: `InMemoryProfileRepository`; resets when the app relaunches.
@MainActor
protocol ProfileRepository: AnyObject {
    func currentProfile() -> ChildProfile?
    func save(_ profile: ChildProfile)
    func quickCheckResult() -> QuickCheckResult?
    func saveQuickCheck(_ result: QuickCheckResult)
}

@MainActor
final class InMemoryProfileRepository: ProfileRepository {
    private var profile: ChildProfile?
    private var result: QuickCheckResult?

    /// Pass `DummyData.sampleProfile` to start past onboarding, or nil to start at the splash.
    init(profile: ChildProfile? = nil, result: QuickCheckResult? = nil) {
        self.profile = profile
        self.result = result
    }

    func currentProfile() -> ChildProfile? {
        profile
    }

    func save(_ profile: ChildProfile) {
        self.profile = profile
    }

    func quickCheckResult() -> QuickCheckResult? {
        result
    }

    func saveQuickCheck(_ result: QuickCheckResult) {
        self.result = result
    }
}
