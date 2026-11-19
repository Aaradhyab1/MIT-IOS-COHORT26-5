import SwiftUI

/// Differentiation game: Mia, Leo and Zoe make sounds; pick the different one.
/// Figma: Precoding_FINAL › 07 · Level 2 — Differentiation.
/// TODO: Build the real game from Figma.
struct OddOneOutView: View {
    @State private var vm: OddOneOutViewModel

    init(vm: OddOneOutViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: vm.title, note: "Which one sounds different?")
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
        OddOneOutView(vm: container.makeOddOneOutViewModel(exerciseId: "differentiation.odd-sound-out"))
    }
    .environment(container)
    .environment(container.router)
}
