import Foundation

/// One tile or card on Listening home: either a collection of exercises
/// ("Story Hide & Seek") or a single exercise ("Name Alert"), with its progress added up.
struct PracticeGroup: Identifiable, Hashable {
    let id: String              // collection name, or the exercise id when there is no collection
    let levelId: String
    let levelNumber: Int
    let title: String
    let collection: String?
    let firstExerciseId: String
    let imageName: String
    let durationMinutes: Int
    var completed: Int
    var target: Int

    /// 0…1 for the progress ring.
    var progressFraction: Double {
        target > 0 ? Double(completed) / Double(target) : 0
    }

    /// "4 of 10", "New" or "Done".
    var detailText: String {
        if completed == 0 { return "New" }
        if completed >= target { return "Done" }
        return "\(completed) of \(target)"
    }

    /// "Level 1 · 4 min" under a review card.
    var metaText: String {
        "Level \(levelNumber) \u{00B7} \(durationMinutes) min"
    }
}
