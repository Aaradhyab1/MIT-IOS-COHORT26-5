import Foundation

/// The exercise in Home's big "Today's practice" card.
struct TodaysPractice: Hashable {
    let exerciseId: String
    let badgeNumber: Int        // number in the badge, e.g. 3
    let badgeText: String       // "You're at Level 3" / "You're on Skill 1"
    let title: String           // "Animals"
    let summary: String         // one line under the title
    let minutesText: String     // "5 min"
    let countText: String       // "10 sounds"
}
