import Testing
@testable import EchoProject

/// Catches broken sample data (a typo in an id crashes the in-memory repository).
@MainActor
struct DummyDataTests {
    @Test func exerciseIdsAreUnique() {
        let ids = DummyData.exercises.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func levelIdsAreUnique() {
        let ids = DummyData.levels.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func everyExerciseListedInALevelExistsAndPointsBack() {
        for level in DummyData.levels {
            for exerciseId in level.exerciseIds {
                let exercise = DummyData.exercises.first { $0.id == exerciseId }
                #expect(exercise != nil, "\(exerciseId) is listed in \(level.id) but missing")
                #expect(exercise?.levelId == level.id, "\(exerciseId) has the wrong levelId")
            }
        }
    }

    @Test func eachTrackHasFourLevelsInOrder() {
        let content = InMemoryContentRepository()
        for track in Track.allCases {
            #expect(content.levels(for: track).map(\.order) == [1, 2, 3, 4])
        }
    }

    @Test func everyCorrectAnswerIsOneOfTheOptions() {
        for exercise in DummyData.exercises {
            for item in exercise.items {
                guard let correct = item.correctOptionId else { continue }
                let optionIds = item.options?.map(\.id) ?? []
                #expect(optionIds.contains(correct), "\(item.id) answer \(correct) is not an option")
            }
        }
    }

    @Test func quickCheckHasEightQuestions() {
        #expect(DummyData.quickCheckQuestions.count == 8)
    }
}
