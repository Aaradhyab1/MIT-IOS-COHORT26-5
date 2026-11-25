import Foundation

/// A small "value over label" figure at the bottom of a learning path card.
struct ProgressPathStat: Identifiable, Hashable {
    let value: String
    let label: String

    var id: String { label }
}
