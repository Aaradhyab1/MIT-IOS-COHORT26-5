import SwiftUI

/// Dimmed screen with a frosted panel: title, subtitle and a ✕ button, then `content`.
/// Shared by "Choose a starting level" and "The 4 levels". Tapping outside the panel closes it.
struct OnboardingOverlay<Content: View>: View {
    let title: String
    let subtitle: String
    let onClose: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 32, style: .continuous)

        ZStack {
            // "Scrim (tap outside to close)". Hidden from VoiceOver: the ✕ button does the same.
            Button(action: onClose) {
                EchoColor.scrim
            }
            .buttonStyle(.plain)
            .ignoresSafeArea()
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .echoFont(.heading, .bold)
                            .foregroundStyle(EchoColor.textPrimary)
                            .accessibilityAddTraits(.isHeader)
                        Text(subtitle)
                            .echoFont(.supporting)
                            .foregroundStyle(EchoColor.textSecondary)
                    }
                    Spacer(minLength: EchoSpacing.s)
                    Button("Close", systemImage: "xmark", action: onClose)
                        .labelStyle(.iconOnly)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(EchoColor.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(EchoColor.overlayControl, in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.7), lineWidth: 1))
                        .buttonStyle(.plain)
                        .padding(.top, -8)
                }
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 23)
                .padding(.top, 25)

                content()
            }
            .frame(maxWidth: 354)
            .background(EchoColor.overlaySheet, in: shape)
            .background(.ultraThinMaterial, in: shape)
            .overlay(shape.stroke(.white.opacity(0.95), lineWidth: 1))
            .echoShadow(.overlaySheet)
            .padding(.horizontal, 24)
            .accessibilityAddTraits(.isModal)
        }
    }
}
