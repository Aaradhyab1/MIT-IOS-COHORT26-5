import Foundation

/// One day in the "This week" streak row.
struct ProgressWeekDay: Identifiable, Hashable {
    enum State: Hashable {
        case practiced
        case missed
        case today
        case upcoming
    }

    let id: Int
    let letter: String
    let name: String
    let state: State
}
