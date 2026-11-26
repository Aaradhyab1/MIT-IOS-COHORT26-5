import Foundation

/// One day's figure for a weekly chart. `value` is nil for days that haven't happened yet.
struct ProgressDayValue: Identifiable, Hashable {
    let id: Int
    let letter: String
    let name: String
    let value: Double?
    let isToday: Bool
}
