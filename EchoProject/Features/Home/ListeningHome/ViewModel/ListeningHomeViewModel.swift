import Foundation
import Observation

/// Listening home: greeting, Today's practice, the current level's categories,
/// games to replay from earlier levels, and the next level (locked).
///
/// Everything is worked out in `refresh()`, which the View calls each time the tab
/// appears, so progress made in an exercise shows straight away.
@Observable
@MainActor
final class ListeningHomeViewModel {
    private(set) var greeting = ""
    private(set) var todaysPractice: TodaysPractice?
    private(set) var currentLevelId = ""
    private(set) var levelTitle = ""
    private(set) var levelSubtitle = ""
    private(set) var categories: [PracticeGroup] = []
    private(set) var reviewSubtitle = ""
    private(set) var reviewCards: [PracticeGroup] = []
    private(set) var upNext: UpNextInfo?

    private let content: any ContentRepository
    private let profile: any ProfileRepository
    private let progress: any ProgressRepository
    private let router: AppRouter
    private let now: () -> Date

    init(
        content: any ContentRepository,
        profile: any ProfileRepository,
        progress: any ProgressRepository,
        router: AppRouter,
        now: @escaping () -> Date = Date.init
    ) {
        self.content = content
        self.profile = profile
        self.progress = progress
        self.router = router
        self.now = now
        refresh()
    }

    // MARK: - Building the screen

    func refresh() {
        greeting = Greeting.text(for: now())

        let levels = content.levels(for: .listening)
        guard !levels.isEmpty else { return }
        let wanted = profile.currentProfile()?.recommendedLevel ?? 1
        let current = levels.first { $0.order == wanted } ?? levels[0]
        currentLevelId = current.id

        // Today's practice: the exercise in progress in this level, else the first one not finished.
        let exercises = content.exercises(inLevel: current.id)
        let pick = exercises.first { isInProgress($0.id) }
            ?? exercises.first { !progress.progress(for: $0.id).isComplete }
            ?? exercises.first
        todaysPractice = pick.map { exercise in
            TodaysPractice(
                exerciseId: exercise.id,
                badgeNumber: current.order,
                badgeText: "You're at Level \(current.order)",
                title: exercise.title,
                summary: exercise.summary,
                minutesText: "\(exercise.durationMinutes) min",
                countText: "\(exercise.repetitions) \(ExerciseInstructions.forType(exercise.type).itemWord)"
            )
        }

        // This level's categories, with today's one first (as in Figma).
        levelTitle = "Level \(current.order) - \(ListeningLevelCopy.title(forLevel: current.order))"
        levelSubtitle = ListeningLevelCopy.subtitle(forLevel: current.order)
        var levelGroups = groups(in: current)
        if let pick, let index = levelGroups.firstIndex(where: { $0.id == (pick.collection ?? pick.id) }) {
            levelGroups.insert(levelGroups.remove(at: index), at: 0)
        }
        categories = levelGroups

        // Replay games from the levels before this one: one card per finished game,
        // so the child can jump straight back into it.
        let earlier = levels.filter { $0.order < current.order }
        reviewCards = earlier.flatMap { reviewGroups(in: $0) }
        reviewSubtitle = Self.replayLine(for: Array(Set(reviewCards.map(\.levelNumber))).sorted())

        // The next level stays locked until this level's games are done.
        if let next = levels.first(where: { $0.order == current.order + 1 }) {
            let remaining = exercises.filter { !progress.progress(for: $0.id).isComplete }.count
            upNext = UpNextInfo(
                eyebrow: "Up next \u{00B7} Level \(next.order)",
                title: ListeningLevelCopy.title(forLevel: next.order),
                detail: "Play \(remaining) more game\(remaining == 1 ? "" : "s") to unlock.",
                imageName: next.illustration
            )
        } else {
            upNext = nil
        }
    }

    // MARK: - Actions

    func didTapStart() {
        guard let todaysPractice else { return }
        router.go(.beforeYouStart(exerciseId: todaysPractice.exerciseId))
    }

    func didTapGroup(_ group: PracticeGroup) {
        if let collection = group.collection {
            router.go(.exerciseCollection(levelId: group.levelId, collection: collection))
        } else {
            router.go(.beforeYouStart(exerciseId: group.firstExerciseId))
        }
    }

    func didTapSeeAll() {
        router.go(.levelLibrary(levelId: currentLevelId))
    }

    /// TODO: open the parent Profile (Figma "15 · Profile & Settings") once it is built.
    func didTapProfile() {}

    // MARK: - Private

    private func isInProgress(_ exerciseId: String) -> Bool {
        let p = progress.progress(for: exerciseId)
        return p.completedCount > 0 && !p.isComplete
    }

    /// Folds a level's exercises into collections ("Story Hide & Seek") and single games.
    private func groups(in level: Level) -> [PracticeGroup] {
        var result: [PracticeGroup] = []
        var indexByKey: [String: Int] = [:]
        for exercise in content.exercises(inLevel: level.id) {
            let key = exercise.collection ?? exercise.id
            let p = progress.progress(for: exercise.id)
            if let index = indexByKey[key] {
                result[index].completed += p.completedCount
                result[index].target += p.targetCount
            } else {
                indexByKey[key] = result.count
                result.append(PracticeGroup(
                    id: key,
                    levelId: level.id,
                    levelNumber: level.order,
                    title: exercise.collection ?? exercise.title,
                    collection: exercise.collection,
                    firstExerciseId: exercise.id,
                    imageName: exercise.illustration,
                    durationMinutes: exercise.durationMinutes,
                    completed: p.completedCount,
                    target: p.targetCount
                ))
            }
        }
        return result
    }

    /// One card per playable game in a level (not folded into collections),
    /// so "Listen for the Animal" and "Hear the Doorbell" get their own cards.
    private func reviewGroups(in level: Level) -> [PracticeGroup] {
        content.exercises(inLevel: level.id)
            .filter { Self.replayableExerciseIds.contains($0.id) }
            .map { exercise in
                let p = progress.progress(for: exercise.id)
                return PracticeGroup(
                    id: exercise.id,
                    levelId: level.id,
                    levelNumber: level.order,
                    title: exercise.title,
                    collection: nil,            // opens the game itself, not the collection list
                    firstExerciseId: exercise.id,
                    imageName: exercise.illustration,
                    durationMinutes: exercise.durationMinutes,
                    completed: p.completedCount,
                    target: p.targetCount
                )
            }
    }

    /// Games from earlier levels that are built and ready to replay.
    /// TODO: add more ids here as their screens are finished.
    private static let replayableExerciseIds: Set<String> = [
        "detection.hide-and-seek.animal",       // Level 1 · Listen for the Animal
        "detection.hide-and-seek.doorbell",     // Level 1 · Hear the Doorbell
        "differentiation.odd-sound-out"         // Level 2 · Odd Sound Out
    ]

    /// [1, 2] → "Replay games from Levels 1 and 2."
    private static func replayLine(for numbers: [Int]) -> String {
        guard let last = numbers.last else { return "" }
        if numbers.count == 1 { return "Replay games from Level \(last)." }
        let firstPart = numbers.dropLast().map(String.init).joined(separator: ", ")
        return "Replay games from Levels \(firstPart) and \(last)."
    }
}
