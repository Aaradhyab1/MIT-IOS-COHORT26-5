import SwiftUI

/// A 46 pt pill for one answer: white with a border when idle, blue when chosen,
/// and slightly pressed in while touched.
struct AnswerOptionButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .echoFont(.body, .semibold)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(isSelected ? EchoColor.textOnAccent : EchoColor.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(isSelected ? EchoColor.accent : .white.opacity(0.9), in: Capsule())
            .overlay(Capsule().stroke(isSelected ? .clear : EchoColor.fieldUnderline, lineWidth: 1))
            .echoShadow(isSelected ? .none : .option)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}
