import Foundation

extension DummyData {

    // MARK: - Onboarding

    /// The 8 Quick Check questions (answered Often / Sometimes / Never).
    static let quickCheckQuestions: [QuickCheckQuestion] = (1...8).map { number in
        QuickCheckQuestion(
            id: "qc-\(number)",
            text: "TODO(copy) Quick Check question \(number) from PRECODING",
            levelOrder: (number + 1) / 2            // 1,1,2,2,3,3,4,4: two questions per level
        )
    }

    /// A child who has finished onboarding, for screens that start past it
    /// (Home, Progress, previews).
    static let sampleProfile = ChildProfile(
        name: nil,
        hearingDevice: .cochlearImplant,
        recommendedLevel: 3,                        // "Great start! Level 3: Sound Identification"
        onboardingCompleted: true
    )

    // MARK: - Progress

    /// Practice on the last three days (a 3-day streak) plus one older session,
    /// so the Progress tab looks populated. Dates are relative to `now`.
    static func sessionHistory(now: Date = Date()) -> [SessionRecord] {
        func daysAgo(_ days: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -days, to: now) ?? now
        }
        return [
            SessionRecord(id: UUID(), exerciseId: "detection.hide-and-seek.animal", startedAt: daysAgo(6), correctCount: 2, totalCount: 2, outcome: .greatJob),
            SessionRecord(id: UUID(), exerciseId: "detection.hide-and-seek.doorbell", startedAt: daysAgo(3), correctCount: 1, totalCount: 2, outcome: .almostThere),
            SessionRecord(id: UUID(), exerciseId: "differentiation.odd-sound-out", startedAt: daysAgo(2), correctCount: 1, totalCount: 1, outcome: .greatJob),
            SessionRecord(id: UUID(), exerciseId: "words.three-letter", startedAt: daysAgo(1), correctCount: 1, totalCount: 1, outcome: .greatJob)
        ]
    }

    /// Starting values for the "3/10" counters on exercise cards.
    static let exerciseProgress: [ExerciseProgress] = [
        ExerciseProgress(exerciseId: "detection.hide-and-seek.animal", completedCount: 10, targetCount: 10, bestOutcome: .greatJob),
        ExerciseProgress(exerciseId: "detection.hide-and-seek.doorbell", completedCount: 3, targetCount: 10, bestOutcome: .almostThere),
        ExerciseProgress(exerciseId: "differentiation.odd-sound-out", completedCount: 1, targetCount: 10, bestOutcome: .greatJob),
        ExerciseProgress(exerciseId: "words.three-letter", completedCount: 2, targetCount: 10, bestOutcome: .greatJob)
    ]
}
