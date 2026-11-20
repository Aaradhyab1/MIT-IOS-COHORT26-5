import Foundation

/// One line in "How scoring works": a label on the left and a value on the right,
/// e.g. "Has the skill · 2 points" or "Level 1 · Detection · Questions 1–2".
struct ScoringRow: Identifiable, Hashable {
    let label: String
    let value: String
    var id: String { label }
}
