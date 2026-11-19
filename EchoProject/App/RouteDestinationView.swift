import SwiftUI

/// Maps each Route to its screen. The only place navigation destinations are built.
///
/// Every screen is built from its ViewModel factory (`container.make…ViewModel`).
/// When you replace a placeholder screen, edit only your own lines here.
struct RouteDestinationView: View {
    @Environment(AppContainer.self) private var container
    let route: Route

    var body: some View {
        switch route {
        // Onboarding — Features/Onboarding
        case .childProfile:
            ChildProfileView(vm: container.makeChildProfileViewModel())
        case .choosePath:
            ChoosePathView(vm: container.makeChoosePathViewModel())
        case .quickCheck:
            QuickCheckView(vm: container.makeQuickCheckViewModel())
        case .quickCheckResult:
            QuickCheckResultView(vm: container.makeQuickCheckResultViewModel())

        // Shared screens — Shared/
        case .levelLibrary(let levelId):
            LevelLibraryView(vm: container.makeLevelLibraryViewModel(levelId: levelId))
        case .exerciseCollection(let levelId, let collection):
            ExerciseCollectionView(vm: container.makeExerciseCollectionViewModel(levelId: levelId, collection: collection))
        case .beforeYouStart(let exerciseId):
            BeforeYouStartView(vm: container.makeBeforeYouStartViewModel(exerciseId: exerciseId))
        case .exercise(let exerciseId):
            exerciseScreen(for: exerciseId)
        case .completion(let exerciseId, let outcome):
            CompletionView(vm: container.makeCompletionViewModel(exerciseId: exerciseId, outcome: outcome))

        // Progress — Features/Progress
        case .listeningProgress:
            ListeningProgressView(vm: container.makeListeningProgressViewModel())
        case .speakingProgress:
            SpeakingProgressView(vm: container.makeSpeakingProgressViewModel())
        }
    }

    /// One screen per exercise template; every exercise of that type reuses it.
    @ViewBuilder
    private func exerciseScreen(for exerciseId: String) -> some View {
        switch container.exerciseType(for: exerciseId) {
        // Listening — Features/Listening/<Level>
        case .listenAndRespond:
            ListenAndRespondView(vm: container.makeListenAndRespondViewModel(exerciseId: exerciseId))
        case .oddOneOut:
            OddOneOutView(vm: container.makeOddOneOutViewModel(exerciseId: exerciseId))
        case .pictureChoice:
            PictureChoiceView(vm: container.makePictureChoiceViewModel(exerciseId: exerciseId))
        case .storyPlayer:
            StoryPlayerView(vm: container.makeStoryPlayerViewModel(exerciseId: exerciseId))
        case .ordering, .matching:
            // Ordering and Matching are played inside each story (StoryPlayerView).
            PlaceholderScreen(title: "Play these inside a story", note: exerciseId)

        // Speaking — Features/Speaking/<Category>
        case .listenAndRecord:
            if container.levelId(for: exerciseId) == "speaking.words" {
                WordsPracticeView(vm: container.makeWordsPracticeViewModel(exerciseId: exerciseId))
            } else {
                SoundsPracticeView(vm: container.makeSoundsPracticeViewModel(exerciseId: exerciseId))
            }
        case .readAlong:
            SentencesPracticeView(vm: container.makeSentencesPracticeViewModel(exerciseId: exerciseId))
        case .conversation:
            ConversationView(vm: container.makeConversationViewModel(exerciseId: exerciseId))

        case nil:
            PlaceholderScreen(title: "Exercise not found", note: exerciseId)
        }
    }
}
