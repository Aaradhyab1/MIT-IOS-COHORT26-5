import SwiftUI

/// Speaking tab home: Sounds, Words, Sentences and Conversation.
/// Figma: Precoding_FINAL › 03 v3 · Home › Home · Speaking.
/// TODO: Build the real layout from Figma. The level buttons below are temporary.
struct SpeakingHomeView: View {
    @State private var vm: SpeakingHomeViewModel

    init(vm: SpeakingHomeViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: "Speaking", note: "Sounds, Words, Sentences, Conversation")
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: EchoSpacing.m) {
                    ForEach(vm.rows) { row in
                        Button(row.title) { vm.didTap(row) }
                            .buttonStyle(.echoSecondary)
                    }
                }
                .padding(.horizontal, EchoSpacing.screenHorizontal)
                .padding(.bottom, EchoSpacing.l)
            }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        SpeakingHomeView(vm: container.makeSpeakingHomeViewModel())
    }
    .environment(container)
    .environment(container.router)
}
