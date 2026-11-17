import Foundation

enum HearingDevice: String, Codable, Hashable, CaseIterable {
    case hearingAid
    case cochlearImplant
    case both
}

/// The child using the app with their parent. Every field is optional
/// because the profile step in onboarding can be skipped.
struct ChildProfile: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String?
    var dateOfBirth: Date?
    var hearingDevice: HearingDevice?
    var activationDate: Date?           // date the aid or implant was switched on
    var recommendedLevel: Int           // Listening level to start at
    var onboardingCompleted: Bool

    init(
        id: UUID = UUID(),
        name: String? = nil,
        dateOfBirth: Date? = nil,
        hearingDevice: HearingDevice? = nil,
        activationDate: Date? = nil,
        recommendedLevel: Int = 1,
        onboardingCompleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.hearingDevice = hearingDevice
        self.activationDate = activationDate
        self.recommendedLevel = recommendedLevel
        self.onboardingCompleted = onboardingCompleted
    }
}
