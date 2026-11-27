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

    @Test func everyStoryHasItsTextAndQuestions() {
        let stories = DummyData.comprehension.filter { $0.type == .storyPlayer }
        #expect(stories.count == 4)

        for story in stories {
            let pages = story.items.filter { $0.options == nil }
            let ordering = story.items.first { $0.id.hasSuffix(StoryItemSuffix.ordering) }
            let matching = story.items.first { $0.id.hasSuffix(StoryItemSuffix.matching) }
            let answers = story.items.first { $0.id.hasSuffix(StoryItemSuffix.matchingAnswers) }

            #expect(!pages.isEmpty, "\(story.id) has no pages")
            #expect(pages.allSatisfy { !($0.text ?? "").isEmpty && !($0.text ?? "").contains("TODO") }, "\(story.id) has placeholder text")
            #expect(ordering?.options?.count == 3, "\(story.id) needs 3 events")
            #expect(matching?.options?.count == 3, "\(story.id) needs 3 characters")
            #expect(matching?.options?.map(\.id) == answers?.options?.map(\.id), "\(story.id) answers must match its characters")
            let labels = (ordering?.options ?? []) + (matching?.options ?? []) + (answers?.options ?? [])
            #expect(labels.allSatisfy { !$0.label.contains("TODO") }, "\(story.id) has placeholder answers")
        }
    }
}
