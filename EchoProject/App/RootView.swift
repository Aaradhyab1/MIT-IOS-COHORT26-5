import SwiftUI

/// Shows onboarding until it is finished, then the three tabs.
struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        if router.isOnboardingComplete {
            MainTabView()
        } else {
            NavigationStack(path: $router.onboardingPath) {
                // TODO(Dev A, Thu 19 Nov): replace with SplashView.
                PlaceholderScreen(title: "Splash", owner: "Dev A", note: "Elephant logo, 3 keyframes")
                    .toolbar {
                        // Dev-only shortcut until onboarding screens exist. Remove on Thu 19 Nov.
                        Button("Skip to Home") { router.finishOnboarding() }
                    }
                    .navigationDestination(for: Route.self) { route in
                        RouteDestinationView(route: route)
                    }
            }
        }
    }
}

#Preview("Onboarding") {
    let container = AppContainer.dummy()
    return RootView()
        .environment(container)
        .environment(container.router)
}

#Preview("Past onboarding") {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return RootView()
        .environment(container)
        .environment(container.router)
}
