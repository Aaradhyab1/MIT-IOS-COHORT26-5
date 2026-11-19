import Foundation

/// ViewModel factories for Level 4 — Comprehension: the story, then Ordering and Matching.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeStoryPlayerViewModel(exerciseId: String) -> StoryPlayerViewModel {
        StoryPlayerViewModel(
            exerciseId: exerciseId,
            content: content,
            narrator: narrator,
            progress: progress,
            router: router
        )
    }
}
