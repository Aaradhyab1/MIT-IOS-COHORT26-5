import Foundation
import Testing
@testable import EchoProject

@MainActor
struct InMemoryProgressRepositoryTests {
    private func makeRepository(sessions: [SessionRecord] = [], now: Date = Date()) -> InMemoryProgressRepository {
        InMemoryProgressRepository(
            content: InMemoryContentRepository(),
            sessions: sessions,
            progress: [],
            now: { now }
        )
    }

    @Test func finishingAnExerciseAddsOneRound() {
        let repository = makeRepository()

        repository.finish(exerciseId: "identification.animals", correct: 2, total: 2)

        let progress = repository.progress(for: "identification.animals")
        #expect(progress.completedCount == 1)
        #expect(progress.targetCount == 10)
        #expect(progress.bestOutcome == .greatJob)
    }

    @Test func aWorseRoundDoesNotLowerTheBestOutcome() {
        let repository = makeRepository()

        repository.finish(exerciseId: "identification.animals", correct: 2, total: 2)
        repository.finish(exerciseId: "identification.animals", correct: 0, total: 2)

        #expect(repository.progress(for: "identification.animals").bestOutcome == .greatJob)
    }

    @Test func untouchedExerciseStartsAtZero() {
        let progress = makeRepository().progress(for: "sounds.vowel")
        #expect(progress.completedCount == 0)
        #expect(progress.isComplete == false)
    }

    @Test func streakCountsConsecutiveDaysEndingYesterday() {
        let now = Date()
        let repository = makeRepository(sessions: DummyData.sessionHistory(now: now), now: now)
        #expect(repository.streakDays() == 3)
    }

    @Test func noSessionsMeansNoStreak() {
        #expect(makeRepository().streakDays() == 0)
    }

    @Test func summaryOnlyCountsSessionsFromItsTrack() {
        let now = Date()
        let repository = makeRepository(sessions: DummyData.sessionHistory(now: now), now: now)

        #expect(repository.summary(for: .listening).sessions == 3)
        #expect(repository.summary(for: .speaking).sessions == 1)
        #expect(repository.summary(for: .listening).levels.count == 4)
    }
}
