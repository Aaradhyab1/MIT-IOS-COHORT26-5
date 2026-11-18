import SwiftUI

/// Maps each Route to its screen. The only place navigation destinations are built.
///
/// As screens are built, each placeholder is replaced by the real View with its
/// ViewModel from an AppContainer factory, for example:
///
///     case .quickCheck:
///         QuickCheckView(vm: container.makeQuickCheckViewModel())
struct RouteDestinationView: View {
    @Environment(AppContainer.self) private var container
    let route: Route

    var body: some View {
        switch route {
        // Onboarding
        case .childProfile:
            PlaceholderScreen(title: "Child profile", note: "Date of birth and device activation date")
        case .choosePath:
            PlaceholderScreen(title: "Choose your path", note: "Quick Check or pick a level")
        case .chooseLevel:
            PlaceholderScreen(title: "Choose a level")
        case .quickCheck:
            PlaceholderScreen(title: "Quick Check", note: "8 questions: Often / Sometimes / Never")
        case .quickCheckResult:
            PlaceholderScreen(title: "Quick Check result", note: "Recommended starting level")

        // Libraries and exercises
        case .levelLibrary(let levelId):
            PlaceholderScreen(title: "Level library", note: levelId)
        case .beforeYouStart(let exerciseId):
            PlaceholderScreen(title: "Before you start", note: exerciseId)
        case .exercise(let exerciseId):
            exerciseScreen(for: exerciseId)
        case .completion(let exerciseId, let outcome):
            PlaceholderScreen(title: "Completion", note: "\(exerciseId) · \(outcome.rawValue)")

        // Progress
        case .listeningProgress:
            PlaceholderScreen(title: "Listening progress")
        case .speakingProgress:
            PlaceholderScreen(title: "Speaking progress")
        }
    }

    /// One template screen per ExerciseType; every exercise of that type reuses it.
    @ViewBuilder
    private func exerciseScreen(for exerciseId: String) -> some View {
        switch container.exerciseType(for: exerciseId) {
        case .listenAndRespond:
            PlaceholderScreen(title: "Listen and respond", note: exerciseId)
        case .oddOneOut:
            PlaceholderScreen(title: "Odd one out", note: exerciseId)
        case .pictureChoice:
            PlaceholderScreen(title: "Picture choice", note: exerciseId)
        case .storyPlayer:
            PlaceholderScreen(title: "Story player", note: exerciseId)
        case .ordering, .matching:
            PlaceholderScreen(title: "Coming soon", note: exerciseId)
        case .listenAndRecord:
            PlaceholderScreen(title: "Listen and record", note: exerciseId)
        case .readAlong:
            PlaceholderScreen(title: "Read along", note: exerciseId)
        case .conversation:
            PlaceholderScreen(title: "Conversation", note: exerciseId)
        case nil:
            PlaceholderScreen(title: "Exercise not found", note: exerciseId)
        }
    }
}
