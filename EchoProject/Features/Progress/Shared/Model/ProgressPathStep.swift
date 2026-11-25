import Foundation

/// One level on "The listening path" / "The speaking path" timeline.
struct ProgressPathStep: Identifiable, Hashable {
    enum State: Hashable {
        /// Finished. `note` is a date or "Done".
        case done(note: String)
        /// The level being worked on now.
        case current(completion: Double, note: String)
        /// Not open yet. `note` is "Locked", "Up next" or "Later".
        case upcoming(note: String)
    }

    let number: Int
    let title: String
    let detail: String?
    let state: State

    var id: Int { number }

    var isDone: Bool {
        if case .done = state { return true }
        return false
    }
}
