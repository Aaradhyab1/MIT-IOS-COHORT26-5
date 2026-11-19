import SwiftUI

@main
struct EchoApp: App {
    /// This release runs on hardcoded dummy data. Pass `startPastOnboarding: true`
    /// while working on the tabs so the app opens straight on Home.
    /// `liveSpeech: true` uses the iPhone's microphone and voices in Speaking and stories.
    @State private var container = AppContainer.dummy(startPastOnboarding: false, liveSpeech: true)

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
                .environment(container.router)
        }
    }
}
