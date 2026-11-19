import SwiftUI

/// Shows onboarding until it is finished, then the three tabs.
///
/// Overlays such as "Leave this practice?" are drawn here, on top of both and above
/// the tab bar, whenever `router.overlay` is set. Exercises never draw their own.
struct RootView: View {
    @Environment(AppContainer.self) private var container
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            content

            if let overlay = router.overlay {
                overlayView(overlay)
                    .transition(.opacity)
                    .zIndex(1) // Keeps the fade-out animation on top of the content.
            }
        }
        .animation(.easeOut(duration: 0.2), value: router.overlay)
    }

    @ViewBuilder
    private var content: some View {
        @Bindable var router = router

        if router.isOnboardingComplete {
            MainTabView()
        } else {
            NavigationStack(path: $router.onboardingPath) {
                SplashView(vm: container.makeSplashViewModel())
                    .navigationDestination(for: Route.self) { route in
                        RouteDestinationView(route: route)
                    }
            }
        }
    }

    @ViewBuilder
    private func overlayView(_ overlay: AppRouter.Overlay) -> some View {
        switch overlay {
        case .leavePractice:
            LeavePracticeOverlay(vm: container.makeLeavePracticeViewModel())
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
