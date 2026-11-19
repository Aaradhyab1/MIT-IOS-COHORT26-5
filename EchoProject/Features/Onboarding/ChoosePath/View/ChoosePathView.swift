import SwiftUI

/// Choose the Quick Check or pick a starting level (custom level overlay).
/// Figma: Precoding_FINAL › 02 · Onboarding › Choose assessment or custom level.
/// TODO: Build the real layout from Figma. Navigation already works through the ViewModel.
struct ChoosePathView: View {
    @State private var vm: ChoosePathViewModel

    init(vm: ChoosePathViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: "Choose your path", note: "Quick Check or pick a level")
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: EchoSpacing.m) {
                Button("Take the Quick Check", action: vm.didTapQuickCheck)
                    .buttonStyle(.echoPrimary)
                Button("Choose a level myself", action: vm.didTapChooseLevel)
                    .buttonStyle(.echoSecondary)
                }
                .padding(.horizontal, EchoSpacing.screenHorizontal)
                .padding(.bottom, EchoSpacing.l)
            }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: false)
    return NavigationStack {
        ChoosePathView(vm: container.makeChoosePathViewModel())
    }
    .environment(container)
    .environment(container.router)
}
