import SwiftUI

/// Launch screen with the Echo elephant.
/// Figma: Precoding_FINAL › 01 · App launch.
/// TODO: Build the real layout from Figma. Navigation already works through the ViewModel.
struct SplashView: View {
    @State private var vm: SplashViewModel

    init(vm: SplashViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: "Splash", note: "Elephant logo animation")
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: EchoSpacing.m) {
                Button("Start", action: vm.didTapStart)
                    .buttonStyle(.echoPrimary)
                Button("Skip to Home", action: vm.didTapSkipToHome)
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
        SplashView(vm: container.makeSplashViewModel())
    }
    .environment(container)
    .environment(container.router)
}
