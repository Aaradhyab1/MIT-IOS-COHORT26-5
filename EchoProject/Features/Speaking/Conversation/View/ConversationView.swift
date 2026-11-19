import SwiftUI

/// Conversation role-play at the ice cream shop: record each reply.
/// Figma: Precoding_FINAL › 14 · Speech — Conversation.
/// TODO: Build the real game from Figma.
struct ConversationView: View {
    @State private var vm: ConversationViewModel

    init(vm: ConversationViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: vm.title, note: "Ice cream shop role-play")
            .safeAreaInset(edge: .bottom) {
                Button("Finish (demo)", action: vm.didTapFinishDemo)
                    .buttonStyle(.echoPrimary)
                    .padding(.horizontal, EchoSpacing.screenHorizontal)
                    .padding(.bottom, EchoSpacing.l)
            }
            .exerciseChrome(onBack: vm.didTapBack)
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        ConversationView(vm: container.makeConversationViewModel(exerciseId: "conversation.ice-cream-shop"))
    }
    .environment(container)
    .environment(container.router)
}
