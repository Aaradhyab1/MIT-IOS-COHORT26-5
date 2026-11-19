import Foundation
import Observation

/// Listening tab home: Today's practice and the level journey.
///
/// Placeholder logic: lists the listening levels so every level library can be reached.
/// Add Today's practice and the level journey here.
@Observable
@MainActor
final class ListeningHomeViewModel {
    struct Row: Identifiable {
        let id: String          // level id
        let title: String
    }

    let rows: [Row]
    private let router: AppRouter

    init(content: any ContentRepository, router: AppRouter) {
        self.router = router
        self.rows = content.levels(for: .listening).map { level in
            Row(id: level.id, title: "Level \(level.order) · \(level.title)")
        }
    }

    func didTap(_ row: Row) {
        router.go(.levelLibrary(levelId: row.id))
    }
}
