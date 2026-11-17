import Foundation

/// Result shown on the completion screen.
enum Outcome: String, Codable, Hashable, CaseIterable {
    case greatJob
    case almostThere
    case keepPractising

    /// Proposed thresholds: 80% and above, 50–79%, under 50%. Confirm with your guide.
    static func from(correct: Int, total: Int) -> Outcome {
        guard total > 0 else { return .keepPractising }
        let ratio = Double(correct) / Double(total)
        if ratio >= 0.8 { return .greatJob }
        if ratio >= 0.5 { return .almostThere }
        return .keepPractising
    }

    /// Higher is better; used to keep the best outcome per exercise.
    var rank: Int {
        switch self {
        case .keepPractising: return 0
        case .almostThere: return 1
        case .greatJob: return 2
        }
    }

    static func best(_ lhs: Outcome?, _ rhs: Outcome) -> Outcome {
        guard let lhs else { return rhs }
        return lhs.rank >= rhs.rank ? lhs : rhs
    }
}

/// One time an exercise was played to the end.
struct SessionRecord: Codable, Identifiable, Hashable {
    let id: UUID
    let exerciseId: String
    let startedAt: Date
    var correctCount: Int
    var totalCount: Int
    var outcome: Outcome?
}

/// Drives the "3/10" on exercise cards.
struct ExerciseProgress: Codable, Hashable {
    let exerciseId: String
    var completedCount: Int
    var targetCount: Int
    var bestOutcome: Outcome?

    var isComplete: Bool { completedCount >= targetCount }
}

struct LevelCompletion: Codable, Hashable, Identifiable {
    var id: String { levelId }
    let levelId: String
    let completedExercises: Int
    let totalExercises: Int
}

/// Everything the Progress tab shows for one track.
struct TrackSummary: Codable, Hashable {
    let track: Track
    let streakDays: Int
    let sessions: Int
    let minutes: Int
    let levels: [LevelCompletion]
}
