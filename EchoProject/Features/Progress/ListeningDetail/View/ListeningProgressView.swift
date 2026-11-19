import SwiftUI

/// Listening progress per level.
/// Figma: Precoding_FINAL › Progress_v2 · Revamp › 02 · Listening.
/// TODO: Build the real layout from Figma. Navigation already works through the ViewModel.
struct ListeningProgressView: View {
    @State private var vm: ListeningProgressViewModel

    init(vm: ListeningProgressViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: "Listening progress", note: "Progress per level")
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        ListeningProgressView(vm: container.makeListeningProgressViewModel())
    }
    .environment(container)
    .environment(container.router)
}
