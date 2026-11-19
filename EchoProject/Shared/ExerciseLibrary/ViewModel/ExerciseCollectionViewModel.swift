import Foundation
import Observation

/// A named group of exercises inside a level, e.g. "Story Hide & Seek" in Detection.
/// Shows one card per exercise with its progress, and opens the exercise on tap.
@Observable
@MainActor
final class ExerciseCollectionViewModel {
    /// Everything one card needs, already worked out, so the View only draws.
    struct Row: Identifiable {
        let id: String
        let title: String
        let illustration: String
        let completed: Int
        let target: Int

        var progressValue: Double { target > 0 ? Double(completed) / Double(target) : 0 }
        var progressText: String { "\(completed) / \(target)" }
    }

    let title: String
    private let levelId: String
    private let content: any ContentRepository
    private let progress: any ProgressRepository
    private let router: AppRouter

    init(
        levelId: String,
        collection: String,
        content: any ContentRepository,
        progress: any ProgressRepository,
        router: AppRouter
    ) {
        self.title = collection
        self.levelId = levelId
        self.content = content
        self.progress = progress
        self.router = router
    }

    /// Computed each time, so the cards show new progress after an exercise is finished.
    var rows: [Row] {
        content.exercises(inLevel: levelId)
            .filter { $0.collection == title }
            .map { exercise in
                let p = progress.progress(for: exercise.id)
                return Row(
                    id: exercise.id,
                    title: exercise.title,
                    illustration: exercise.illustration,
                    completed: p.completedCount,
                    target: p.targetCount
                )
            }
    }

    /// Every exercise opens through the shared "Before you start" screen.
    func rowTapped(_ row: Row) {
        router.go(.beforeYouStart(exerciseId: row.id))
    }

    func backTapped() {
        router.back()
    }
}
