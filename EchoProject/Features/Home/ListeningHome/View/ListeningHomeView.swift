import SwiftUI

/// Listening tab home: Today's practice and the level journey.
/// Figma: Precoding_FINAL › 03 v3 · Home › Home · Listening.
/// TODO: Build the real layout from Figma. The level buttons below are temporary.
struct ListeningHomeView: View {
    @State private var vm: ListeningHomeViewModel

    init(vm: ListeningHomeViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: "Listening", note: "Today's practice and the level journey")
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
        ListeningHomeView(vm: container.makeListeningHomeViewModel())
    }
    .environment(container)
    .environment(container.router)
}
