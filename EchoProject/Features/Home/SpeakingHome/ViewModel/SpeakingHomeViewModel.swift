import Foundation
import Observation

/// Speaking tab home: Sounds, Words, Sentences and Conversation.
///
/// Placeholder logic: lists the speaking levels so every level library can be reached.
/// Add Today's practice and the level journey here.
@Observable
@MainActor
final class SpeakingHomeViewModel {
    struct Row: Identifiable {
        let id: String          // level id
        let title: String
    }

    let rows: [Row]
    private let router: AppRouter

    init(content: any ContentRepository, router: AppRouter) {
        self.router = router
        self.rows = content.levels(for: .speaking).map { level in
            Row(id: level.id, title: level.title)
        }
    }

    func didTap(_ row: Row) {
        router.go(.levelLibrary(levelId: row.id))
    }
}
