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
                // TODO: Replace with SplashView.
                PlaceholderScreen(title: "Splash", note: "Elephant logo animation")
                    .toolbar {
                        // Development shortcut while the onboarding screens are being built.
                        // Remove once SplashView navigates to the child profile.
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
