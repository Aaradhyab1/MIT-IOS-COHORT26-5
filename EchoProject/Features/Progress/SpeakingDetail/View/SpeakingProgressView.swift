import SwiftUI

/// Speaking progress per category.
/// Figma: Precoding_FINAL › Progress_v2 · Revamp › 03 · Speaking.
/// TODO: Build the real layout from Figma. Navigation already works through the ViewModel.
struct SpeakingProgressView: View {
    @State private var vm: SpeakingProgressViewModel

    init(vm: SpeakingProgressViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: "Speaking progress", note: "Progress per category")
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        SpeakingProgressView(vm: container.makeSpeakingProgressViewModel())
    }
    .environment(container)
    .environment(container.router)
}
