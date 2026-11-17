import Foundation

/// What exercises exist. Read-only.
/// This release: `InMemoryContentRepository` serving `DummyData`.
@MainActor
protocol ContentRepository: AnyObject {
    func levels(for track: Track) -> [Level]
    func level(id: String) -> Level?
    func exercises(inLevel levelId: String) -> [Exercise]
    func exercise(id: String) -> Exercise?
    func quickCheckQuestions() -> [QuickCheckQuestion]
}

@MainActor
final class InMemoryContentRepository: ContentRepository {
    private let levelsById: [String: Level]
    private let exercisesById: [String: Exercise]
    private let questions: [QuickCheckQuestion]

    init(
        levels: [Level] = DummyData.levels,
        exercises: [Exercise] = DummyData.exercises,
        questions: [QuickCheckQuestion] = DummyData.quickCheckQuestions
    ) {
        self.levelsById = Dictionary(uniqueKeysWithValues: levels.map { ($0.id, $0) })
        self.exercisesById = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })
        self.questions = questions
    }

    func levels(for track: Track) -> [Level] {
        levelsById.values
            .filter { $0.track == track }
            .sorted { $0.order < $1.order }
    }

    func level(id: String) -> Level? {
        levelsById[id]
    }

    func exercises(inLevel levelId: String) -> [Exercise] {
        guard let level = levelsById[levelId] else { return [] }
        return level.exerciseIds.compactMap { exercisesById[$0] }
    }

    func exercise(id: String) -> Exercise? {
        exercisesById[id]
    }

    func quickCheckQuestions() -> [QuickCheckQuestion] {
        questions
    }
}
