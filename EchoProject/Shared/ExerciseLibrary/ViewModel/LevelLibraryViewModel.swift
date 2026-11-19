import Foundation
import Observation

/// State for the exercise list of one level, e.g. Listening › Differentiation.
///
/// Exercises that share a `collection` (e.g. "Which One Sounds Different") are grouped
/// into one section under that name; exercises without one share an untitled section.
@Observable
@MainActor
final class LevelLibraryViewModel {

    /// Everything the screen can show. One enum instead of loose booleans.
    enum State: Equatable {
        case loading
        case ready(title: String, sections: [Section])
        case error(String)
    }

    /// A run of exercise cards, optionally under a collection heading.
    struct Section: Identifiable, Hashable {
        let id: String
        let title: String?          // collection name, nil for ungrouped exercises
        var rows: [Row]
    }

    /// One exercise card: artwork, title and the "3 / 10" progress line.
    struct Row: Identifiable, Hashable {
        let id: String              // exercise id
        let title: String
        let illustration: String
        let completedCount: Int
        let targetCount: Int

        /// 0...1, drives the progress bar.
        var fraction: Double {
            guard targetCount > 0 else { return 0 }
            return min(Double(completedCount) / Double(targetCount), 1)
        }

        /// "0 / 10"
        var countText: String { "\(completedCount) / \(targetCount)" }

        /// Spoken by VoiceOver for the progress line.
        var accessibilityProgress: String { "\(completedCount) of \(targetCount) done" }
    }

    let levelId: String
    private(set) var state: State = .loading

    private let content: any ContentRepository
    private let progress: any ProgressRepository
    private let router: AppRouter

    init(
        levelId: String,
        content: any ContentRepository,
        progress: any ProgressRepository,
        router: AppRouter
    ) {
        self.levelId = levelId
        self.content = content
        self.progress = progress
        self.router = router
        load()
    }

    /// Reads the level again. Called on appear, so the "3 / 10" counts are fresh
    /// after coming back from an exercise.
    func load() {
        guard let level = content.level(id: levelId) else {
            state = .error("This level could not be found.")
            return
        }

        var sections: [Section] = []
        for exercise in content.exercises(inLevel: levelId) {
            let row = makeRow(for: exercise)
            // Keep consecutive exercises with the same collection (or none) together.
            if let last = sections.last, last.title == exercise.collection {
                sections[sections.count - 1].rows.append(row)
            } else {
                let id = exercise.collection ?? "ungrouped-\(sections.count)"
                sections.append(Section(id: id, title: exercise.collection, rows: [row]))
            }
        }
        state = .ready(title: level.title, sections: sections)
    }

    /// Tapping a card opens the shared "Before you start" screen for that exercise.
    func didTap(_ row: Row) {
        router.go(.beforeYouStart(exerciseId: row.id))
    }

    private func makeRow(for exercise: Exercise) -> Row {
        let current = progress.progress(for: exercise.id)
        return Row(
            id: exercise.id,
            title: exercise.title,
            illustration: exercise.illustration,
            completedCount: current.completedCount,
            targetCount: current.targetCount
        )
    }
}
