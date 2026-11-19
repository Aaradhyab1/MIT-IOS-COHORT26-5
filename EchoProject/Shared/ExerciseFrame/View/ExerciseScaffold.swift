import SwiftUI

/// The frame an exercise screen can sit in: landscape background, back button,
/// centred title and the exercise's own content.
///
/// The back button should call a ViewModel method that runs `router.presentLeavePractice()`;
/// RootView then shows the one shared "Leave this practice?" overlay.
///
///     ExerciseScaffold(title: "Did you hear it?", onBack: vm.backTapped) {
///         // exercise content
///     }
struct ExerciseScaffold<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    let onBack: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                EchoIconButton(systemImage: "chevron.left", accessibilityLabel: "Back", action: onBack)
                Spacer()
            }

            VStack(spacing: EchoSpacing.xs) {
                Text(title)
                    .echoFont(.title, .bold)
                    .foregroundStyle(EchoColor.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .echoFont(.supporting)
                        .foregroundStyle(EchoColor.textTertiary)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.top, 19)
            .frame(height: 96, alignment: .top)
            .padding(.top, 20)

            content()
        }
        .padding(.horizontal, EchoSpacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .echoExerciseBackground()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}
