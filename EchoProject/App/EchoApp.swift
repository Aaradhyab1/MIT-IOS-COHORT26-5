import SwiftUI

@main
struct EchoApp: App {
    /// This release runs on dummy data and services. Pass `startPastOnboarding: true`
    /// while working on the tabs so the app opens straight on Home.
    @State private var container = AppContainer.dummy(startPastOnboarding: false)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
                .environment(container.router)
        }
    }
}
