import SwiftUI

/// Identification game: hear a sound, pick it from four pictures.
/// Figma: Precoding_FINAL › 08 · Level 3 — Instruments, 09 · Level 3 — Animals.
/// TODO: Build the real game from Figma.
struct PictureChoiceView: View {
    @State private var vm: PictureChoiceViewModel

    init(vm: PictureChoiceViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: vm.title, note: "Hear a sound, pick the picture")
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
        PictureChoiceView(vm: container.makePictureChoiceViewModel(exerciseId: "identification.animals"))
    }
    .environment(container)
    .environment(container.router)
}
