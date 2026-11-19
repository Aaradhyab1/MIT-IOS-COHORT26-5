import Foundation

/// ViewModel factories for the shared exercise lists: a level's library and a named collection inside it.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeLevelLibraryViewModel(levelId: String) -> LevelLibraryViewModel {
        LevelLibraryViewModel(levelId: levelId, content: content, progress: progress, router: router)
    }

    func makeExerciseCollectionViewModel(levelId: String, collection: String) -> ExerciseCollectionViewModel {
        ExerciseCollectionViewModel(
            levelId: levelId,
            collection: collection,
            content: content,
            progress: progress,
            router: router
        )
    }
}
