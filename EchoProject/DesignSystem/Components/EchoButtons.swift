import SwiftUI

/// Style for the main call to action on a screen, such as "Start" or "Continue".
///
/// Full-width blue capsule with a soft glow. Dims when disabled and shrinks slightly
/// while pressed. Add horizontal padding at the call site to narrow it.
///
///     Button("Start", action: viewModel.start)
///         .buttonStyle(.echoPrimary)
struct EchoPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .echoFont(.body, .semibold)
            .foregroundStyle(EchoColor.textOnAccent)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(EchoColor.accentFill, in: Capsule())
            .echoShadow(isEnabled ? .primaryButton : .none)
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == EchoPrimaryButtonStyle {
    /// See `EchoPrimaryButtonStyle`.
    static var echoPrimary: EchoPrimaryButtonStyle { .init() }
}

/// Round 44 pt Liquid Glass button showing an SF Symbol.
/// Used for profile, back and close actions that float over content.
struct EchoIconButton: View {
    /// SF Symbol name, e.g. `"person.fill"`.
    let systemImage: String
    /// Spoken by VoiceOver, since the button has no visible text.
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundStyle(.black)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .circle)
        .accessibilityLabel(accessibilityLabel)
    }
}
