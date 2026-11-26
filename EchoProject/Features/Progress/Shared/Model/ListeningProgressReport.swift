import Foundation

/// Everything the Listening progress screen shows.
struct ListeningProgressReport: Hashable {
    let subtitle: String
    let level: ProgressLevel
    /// 0...1 average for the week so far.
    let weeklyAccuracy: Double
    /// Change against last week, in percentage points as a fraction (0.06 = 6%).
    let accuracyChange: Double
    /// Daily accuracy, 0...1.
    let dailyAccuracy: [ProgressDayValue]
    let skills: [ProgressSkill]
    let path: [ProgressPathStep]
    let footnote: String
}
