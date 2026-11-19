import SwiftUI

/// Progress tab: streak, sessions and learning paths.
/// Figma: Precoding_FINAL › Progress_v2 · Revamp › 01 · Overview.
/// TODO: Build the real layout from Figma. Navigation already works through the ViewModel.
struct ProgressOverviewView: View {
    @State private var vm: ProgressOverviewViewModel

    init(vm: ProgressOverviewViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: "Progress", note: "Streak, sessions and learning paths")
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: EchoSpacing.m) {
                Button("Listening progress", action: vm.didTapListening)
                    .buttonStyle(.echoSecondary)
                Button("Speaking progress", action: vm.didTapSpeaking)
                    .buttonStyle(.echoSecondary)
                }
                .padding(.horizontal, EchoSpacing.screenHorizontal)
                .padding(.bottom, EchoSpacing.l)
            }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        ProgressOverviewView(vm: container.makeProgressOverviewViewModel())
    }
    .environment(container)
    .environment(container.router)
}
