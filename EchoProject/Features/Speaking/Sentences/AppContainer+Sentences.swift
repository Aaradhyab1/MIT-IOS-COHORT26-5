import Foundation

/// ViewModel factories for Speaking — Sentences.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeSentencesPracticeViewModel(exerciseId: String) -> SentencesPracticeViewModel {
        SentencesPracticeViewModel(exerciseId: exerciseId, content: content, progress: progress, router: router)
    }
}
