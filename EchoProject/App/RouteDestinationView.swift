import SwiftUI

/// Maps each Route to its screen. The only place destinations are built.
///
/// As screens land, replace a placeholder with the real View, built from a
/// ViewModel factory on AppContainer:
///
///     case .quickCheck:
///         QuickCheckView(vm: container.makeQuickCheckViewModel())
///
/// For `.exercise`, look up the exercise type and pick the template View.
struct RouteDestinationView: View {
    @Environment(AppContainer.self) private var container
    let route: Route

    var body: some View {
        switch route {
        // Onboarding — Dev A
        case .childProfile:
            PlaceholderScreen(title: "Child profile", owner: "Dev A")
        case .choosePath:
            PlaceholderScreen(title: "Choose your path", owner: "Dev A", note: "Quick Check or pick a level")
        case .chooseLevel:
            PlaceholderScreen(title: "Choose a level", owner: "Dev A")
        case .quickCheck:
            PlaceholderScreen(title: "Quick Check", owner: "Dev A", note: "8 questions: Often / Sometimes / Never")
        case .quickCheckResult:
            PlaceholderScreen(title: "Quick Check result", owner: "Dev A", note: "Great start! Level 3")

        // Libraries and exercises — Dev B (Listening), Dev C (Speaking), Dev D (stories)
        case .levelLibrary(let levelId):
            PlaceholderScreen(title: "Level library", owner: "Dev B / Dev C", note: levelId)
        case .beforeYouStart(let exerciseId):
            PlaceholderScreen(title: "Before you start", owner: "Dev A", note: exerciseId)
        case .exercise(let exerciseId):
            exerciseScreen(for: exerciseId)
        case .completion(let exerciseId, let outcome):
            PlaceholderScreen(title: "Completion", owner: "Dev B", note: "\(exerciseId) · \(outcome.rawValue)")

        // Progress — Dev D
        case .listeningProgress:
            PlaceholderScreen(title: "Listening progress", owner: "Dev D")
        case .speakingProgress:
            PlaceholderScreen(title: "Speaking progress", owner: "Dev D")
        }
    }

    @ViewBuilder
    private func exerciseScreen(for exerciseId: String) -> some View {
        switch container.content.exercise(id: exerciseId)?.type {
        case .listenAndRespond:
            PlaceholderScreen(title: "Listen and respond", owner: "Dev B", note: exerciseId)
        case .oddOneOut:
            PlaceholderScreen(title: "Odd one out", owner: "Dev B", note: exerciseId)
        case .pictureChoice:
            PlaceholderScreen(title: "Picture choice", owner: "Dev B", note: exerciseId)
        case .storyPlayer:
            PlaceholderScreen(title: "Story player", owner: "Dev D", note: exerciseId)
        case .ordering, .matching:
            PlaceholderScreen(title: "Coming soon", owner: "Cut list", note: exerciseId)
        case .listenAndRecord:
            PlaceholderScreen(title: "Listen and record", owner: "Dev C", note: exerciseId)
        case .readAlong:
            PlaceholderScreen(title: "Read along", owner: "Dev C", note: exerciseId)
        case .conversation:
            PlaceholderScreen(title: "Conversation", owner: "Dev C", note: exerciseId)
        case nil:
            PlaceholderScreen(title: "Unknown exercise", owner: "—", note: exerciseId)
        }
    }
}
