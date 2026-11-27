import SwiftUI

/// "Quick Check": one question card at a time, dots showing progress, Leo and Echo listening below.
/// Figma: Precoding_FINAL › 02 · Onboarding › onboarding-listening-questionnaire (questions 1–8).
struct QuickCheckView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var vm: QuickCheckViewModel

    init(vm: QuickCheckViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            EchoIconButton(systemImage: "chevron.left", accessibilityLabel: "Back", action: vm.didTapBack)
                .padding(.top, 3)

            Text("Quick Check")
                .echoFont(.display, .bold)
                .foregroundStyle(EchoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 15)

            Text("Choose the answer that fits your child best.")
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.textSecondary)
                .padding(.top, EchoSpacing.s)

            Spacer(minLength: EchoSpacing.xl)
                .frame(maxHeight: 72)

            if let question = vm.currentQuestion {
                QuestionCard(vm: vm, question: question)
                    .id(question.id)
                    .transition(cardTransition)
            }

            QuestionProgressDots(count: vm.questions.count, current: vm.currentIndex)
                .frame(maxWidth: .infinity)
                .padding(.top, EchoSpacing.l)

            Spacer(minLength: EchoSpacing.l)

            // Figma: "Art · Duo · Listening". Shrinks on small screens.
            EchoAssetImage(name: "img_duo_listening")
                .frame(maxWidth: 176, maxHeight: 176)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, EchoSpacing.screenHorizontal)
        .padding(.bottom, EchoSpacing.l)
        .animation(.snappy(duration: 0.35), value: vm.currentIndex)
        .echoScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    /// The next card slides in from the right; with Reduce Motion it fades instead.
    private var cardTransition: AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                          removal: .move(edge: .leading).combined(with: .opacity))
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
