import SwiftUI

/// Sentences practice: read along and tap any word to hear it.
/// Figma: Precoding_FINAL › 13 · Speech — Paragraphs (Sentences).
/// TODO: Build the real game from Figma.
struct SentencesPracticeView: View {
    @State private var vm: SentencesPracticeViewModel

    init(vm: SentencesPracticeViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        PlaceholderScreen(title: vm.title, note: "Read along, tap a word to hear it")
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
        SentencesPracticeView(vm: container.makeSentencesPracticeViewModel(exerciseId: "sentences.sentence-1"))
    }
    .environment(container)
    .environment(container.router)
}
