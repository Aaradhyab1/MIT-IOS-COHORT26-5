import SwiftUI

/// The Listening / Speaking / Progress tab shell. Each tab keeps its own
/// navigation stack, so switching tabs does not lose your place.
struct MainTabView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab("Listening", systemImage: "ear", value: AppTab.listening) {
                NavigationStack(path: $router.listeningPath) {
                    ListeningHomeView(vm: container.makeListeningHomeViewModel())
                        .withRouteDestinations()
                }
            }

            Tab("Speaking", systemImage: "waveform", value: AppTab.speaking) {
                NavigationStack(path: $router.speakingPath) {
                    SpeakingHomeView(vm: container.makeSpeakingHomeViewModel())
                        .withRouteDestinations()
                }
            }

            Tab("Progress", systemImage: "chart.bar", value: AppTab.progress) {
                NavigationStack(path: $router.progressPath) {
                    ProgressOverviewView(vm: container.makeProgressOverviewViewModel())
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
