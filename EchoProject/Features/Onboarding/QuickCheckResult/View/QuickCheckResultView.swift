import SwiftUI

/// Result reveal and "Great start!" with the recommended level.
/// Figma: Precoding_FINAL › 02 · Onboarding › Assessment / Result reveal, Great start / Level 3.
/// TODO: Build the real layout from Figma. Navigation already works through the ViewModel.
struct QuickCheckResultView: View {
    @State private var vm: QuickCheckResultViewModel

    init(vm: QuickCheckResultViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: "Quick Check result", note: "Recommended starting level")
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: EchoSpacing.m) {
                Button("Go to Home", action: vm.didTapGoHome)
                    .buttonStyle(.echoPrimary)
                }
                .padding(.horizontal, EchoSpacing.screenHorizontal)
                .padding(.bottom, EchoSpacing.l)
            }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: false)
    return NavigationStack {
        QuickCheckResultView(vm: container.makeQuickCheckResultViewModel())
    }
    .environment(container)
    .environment(container.router)
}
