import Testing
@testable import EchoProject

@MainActor
struct OutcomeTests {
    @Test func eightyPercentOrMoreIsGreatJob() {
        #expect(Outcome.from(correct: 8, total: 10) == .greatJob)
        #expect(Outcome.from(correct: 2, total: 2) == .greatJob)
    }

    @Test func fiftyToSeventyNinePercentIsAlmostThere() {
        #expect(Outcome.from(correct: 5, total: 10) == .almostThere)
        #expect(Outcome.from(correct: 7, total: 10) == .almostThere)
    }

    @Test func underFiftyPercentIsKeepPractising() {
        #expect(Outcome.from(correct: 4, total: 10) == .keepPractising)
    }

    @Test func emptyExerciseIsKeepPractising() {
        #expect(Outcome.from(correct: 0, total: 0) == .keepPractising)
    }

    @Test func bestKeepsTheHigherOutcome() {
        #expect(Outcome.best(.greatJob, .keepPractising) == .greatJob)
        #expect(Outcome.best(nil, .almostThere) == .almostThere)
    }
}
