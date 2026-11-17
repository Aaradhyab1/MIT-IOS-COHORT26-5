import SwiftUI

@main
struct EchoApp: App {
    /// Dummy services for the Nov 30 review. Pass `startPastOnboarding: true`
    /// while working on tabs so the app opens straight on Home.
    @State private var container = AppContainer.dummy(startPastOnboarding: false)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
                .environment(container.router)
        }
    }
}


