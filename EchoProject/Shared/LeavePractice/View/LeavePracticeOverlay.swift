import SwiftUI

/// Dimmed full-screen layer with the "Leave this practice?" card in the middle.
/// Figma: "Overlay — Leave this practice" / "Identification / Leave practice".
/// Shown by RootView in a ZStack above every tab.
struct LeavePracticeOverlay: View {
    @State private var vm: LeavePracticeViewModel

    init(vm: LeavePracticeViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ZStack {
            // Dims the exercise behind; tapping it does nothing, the child must choose.
            EchoColor.scrim
                .ignoresSafeArea()

            card
                .padding(.horizontal, EchoSpacing.screenHorizontal)
        }
    }

    private var card: some View {
        let shape = RoundedRectangle(cornerRadius: 30, style: .continuous)

        return VStack(spacing: 0) {
            Image(systemName: "xmark")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(EchoColor.danger)
                .frame(width: 54, height: 54)
                .background(EchoColor.dangerSurface, in: Circle())
                .accessibilityHidden(true)

            Text("Leave this practice?")
                .echoFont(.heading, .bold)
                .foregroundStyle(EchoColor.textPrimary)
                .padding(.top, EchoSpacing.l)
                .accessibilityAddTraits(.isHeader)

            Text("Your progress in this practice won’t be saved. Are you sure you want to leave?")
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.textSecondary)
                .padding(.top, EchoSpacing.s)

            VStack(spacing: EchoSpacing.m) {
                Button("Keep practicing", action: vm.keepPractising)
                    .buttonStyle(.echoPrimary)
                Button("Leave", action: vm.leave)
                    .buttonStyle(.echoSecondary)
            }
            .frame(maxWidth: 280)
            .padding(.top, EchoSpacing.xl)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.vertical, 25)
        .frame(maxWidth: 362)
        .background(EchoColor.alertSurface, in: shape)
        .background(.ultraThinMaterial, in: shape)
        .overlay(shape.stroke(EchoColor.surfaceStroke, lineWidth: 1))
        .echoShadow(.alert)
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return ZStack {
        PlaceholderScreen(title: "Animals", note: "Exercise behind the overlay")
        LeavePracticeOverlay(vm: container.makeLeavePracticeViewModel())
    }
}
