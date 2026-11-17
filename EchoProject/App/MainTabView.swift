import SwiftUI

/// The Listening / Speaking / Progress tab shell. Each tab owns its own stack.
struct MainTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab("Listening", systemImage: "ear", value: AppTab.listening) {
                NavigationStack(path: $router.listeningPath) {
                    // TODO(Dev A, Sat 21 Nov): replace with HomeView.
                    PlaceholderScreen(title: "Listening", owner: "Dev A", note: "Today's practice card, level journey path")
                        .withRouteDestinations()
                }
            }

            Tab("Speaking", systemImage: "waveform", value: AppTab.speaking) {
                NavigationStack(path: $router.speakingPath) {
                    // TODO(Dev A, Sun 22 Nov): replace with SpeakingHomeView.
                    PlaceholderScreen(title: "Speaking", owner: "Dev A", note: "Sounds, Words, Paragraphs, Conversation")
                        .withRouteDestinations()
                }
            }

            Tab("Progress", systemImage: "chart.bar", value: AppTab.progress) {
                NavigationStack(path: $router.progressPath) {
                    // TODO(Dev D, Sat 21 Nov): replace with ProgressOverviewView.
                    PlaceholderScreen(title: "Progress", owner: "Dev D", note: "Streak, sessions, learning paths")
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
