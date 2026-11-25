import Foundation

/// The hero card on the Progress overview: streak, sessions and the week's days.
struct ProgressWeekSummary: Hashable {
    let streakDays: Int
    let sessions: Int
    let days: [ProgressWeekDay]
}
