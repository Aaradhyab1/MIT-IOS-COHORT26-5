import SwiftUI

/// The 8-question Quick Check: Often / Sometimes / Never.
/// Figma: Precoding_FINAL › 02 · Onboarding › onboarding-listening-questionnaire.
/// TODO: Build the real layout from Figma. Navigation already works through the ViewModel.
struct QuickCheckView: View {
    @State private var vm: QuickCheckViewModel

    init(vm: QuickCheckViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: "Quick Check", note: "8 questions: Often / Sometimes / Never")
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: EchoSpacing.m) {
                Button("See result (demo)", action: vm.didTapSeeResult)
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
        QuickCheckView(vm: container.makeQuickCheckViewModel())
    }
    .environment(container)
    .environment(container.router)
}
