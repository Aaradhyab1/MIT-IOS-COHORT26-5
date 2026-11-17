import Foundation

/// Sessions, per-exercise progress and Progress-tab summaries.
/// This release: `InMemoryProgressRepository`, pre-filled from `DummyData`
/// and updated in memory while the app is open.
@MainActor
protocol ProgressRepository: AnyObject {
    /// Call when an exercise reaches its completion screen.
    @discardableResult
    func finish(exerciseId: String, correct: Int, total: Int) -> Outcome
    func progress(for exerciseId: String) -> ExerciseProgress
    func summary(for track: Track) -> TrackSummary
}

@MainActor
final class InMemoryProgressRepository: ProgressRepository {
    private let content: any ContentRepository
    private var sessions: [SessionRecord]
    private var progressByExercise: [String: ExerciseProgress]
    private let now: () -> Date

    init(
        content: any ContentRepository,
        sessions: [SessionRecord] = DummyData.sessionHistory(),
        progress: [ExerciseProgress] = DummyData.exerciseProgress,
        now: @escaping () -> Date = Date.init
    ) {
        self.content = content
        self.sessions = sessions
        self.progressByExercise = Dictionary(uniqueKeysWithValues: progress.map { ($0.exerciseId, $0) })
        self.now = now
    }

    @discardableResult
    func finish(exerciseId: String, correct: Int, total: Int) -> Outcome {
        let outcome = Outcome.from(correct: correct, total: total)
        sessions.append(
            SessionRecord(
                id: UUID(),
                exerciseId: exerciseId,
                startedAt: now(),
                correctCount: correct,
                totalCount: total,
                outcome: outcome
            )
        )
        var current = progress(for: exerciseId)
        current.completedCount = min(current.completedCount + 1, current.targetCount)
        current.bestOutcome = Outcome.best(current.bestOutcome, outcome)
        progressByExercise[exerciseId] = current
        return outcome
    }

    func progress(for exerciseId: String) -> ExerciseProgress {
        if let stored = progressByExercise[exerciseId] {
            return stored
        }
        let target = content.exercise(id: exerciseId)?.repetitions ?? 10
        return ExerciseProgress(exerciseId: exerciseId, completedCount: 0, targetCount: target, bestOutcome: nil)
    }

    func summary(for track: Track) -> TrackSummary {
        let levels = content.levels(for: track)
        let exerciseIds = Set(levels.flatMap(\.exerciseIds))
        let trackSessions = sessions.filter { exerciseIds.contains($0.exerciseId) }
        let minutes = trackSessions.reduce(0) { total, session in
            total + (content.exercise(id: session.exerciseId)?.durationMinutes ?? 0)
        }
        let completions = levels.map { level in
            LevelCompletion(
                levelId: level.id,
                completedExercises: level.exerciseIds.filter { progress(for: $0).isComplete }.count,
                totalExercises: level.exerciseIds.count
            )
        }
        return TrackSummary(
            track: track,
            streakDays: streakDays(),
            sessions: trackSessions.count,
            minutes: minutes,
            levels: completions
        )
    }

    /// Consecutive days with at least one session, ending today (or yesterday,
    /// so the streak does not drop to 0 before today's practice).
    func streakDays() -> Int {
        let calendar = Calendar.current
        let practisedDays = Set(sessions.map { calendar.startOfDay(for: $0.startedAt) })
        var day = calendar.startOfDay(for: now())

        if !practisedDays.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day),
                  practisedDays.contains(yesterday) else { return 0 }
            day = yesterday
        }

        var streak = 0
        while practisedDays.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }
}
