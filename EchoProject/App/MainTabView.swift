import SwiftUI

/// The Listening / Speaking / Progress tab shell. Each tab keeps its own
/// navigation stack, so switching tabs does not lose your place.
struct MainTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab("Listening", systemImage: "ear", value: AppTab.listening) {
                NavigationStack(path: $router.listeningPath) {
                    // TODO: Replace with HomeView.
                    PlaceholderScreen(title: "Listening", note: "Today's practice and the level journey")
                        .withRouteDestinations()
                }
            }

            Tab("Speaking", systemImage: "waveform", value: AppTab.speaking) {
                NavigationStack(path: $router.speakingPath) {
                    // TODO: Replace with SpeakingHomeView.
                    PlaceholderScreen(title: "Speaking", note: "Sounds, Words, Paragraphs, Conversation")
                        .withRouteDestinations()
                }
            }

            Tab("Progress", systemImage: "chart.bar", value: AppTab.progress) {
                NavigationStack(path: $router.progressPath) {
                    // TODO: Replace with ProgressOverviewView.
                    PlaceholderScreen(title: "Progress", note: "Streak, sessions and learning paths")
                        .withRouteDestinations()
                }
            }
        }
    }
}

private extension View {
    func withRouteDestinations() -> some View {
        navigationDestination(for: Route.self) { route in
            RouteDestinationView(route: route)
        }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return MainTabView()
        .environment(container)
        .environment(container.router)
}
