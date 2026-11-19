import SwiftUI

/// Optional child profile: date of birth and device activation date.
/// Figma: Precoding_FINAL › 02 · Onboarding › Child profile — optional.
/// TODO: Build the real layout from Figma. Navigation already works through the ViewModel.
struct ChildProfileView: View {
    @State private var vm: ChildProfileViewModel

    init(vm: ChildProfileViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: "Child profile", note: "Date of birth and activation date")
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: EchoSpacing.m) {
                Button("Continue", action: vm.didTapContinue)
                    .buttonStyle(.echoPrimary)
                Button("Skip", action: vm.didTapSkip)
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
        ChildProfileView(vm: container.makeChildProfileViewModel())
    }
    .environment(container)
    .environment(container.router)
}
