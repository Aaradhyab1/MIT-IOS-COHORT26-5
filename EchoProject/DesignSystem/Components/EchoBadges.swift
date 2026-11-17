import SwiftUI

/// Small capsule showing a fact about an exercise, such as its length or number of items.
///
///     EchoMetaPill(text: "5 min", systemImage: "clock")
struct EchoMetaPill: View {
    let text: String
    /// Optional SF Symbol shown before the text.
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: EchoSpacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(text)
        }
        .echoFont(.caption, .semibold)
        .foregroundStyle(EchoColor.accent)
        .padding(.vertical, 7)
        .padding(.horizontal, EchoSpacing.m)
        .background(EchoColor.pillSurface, in: Capsule())
    }
}

/// Floating badge showing the child's current level, e.g. "③ You're at Level 3".
/// Pinned to the top of the Home hero card.
struct EchoLevelBadge: View {
    let level: Int
    let text: String

    var body: some View {
        HStack(spacing: EchoSpacing.s) {
            Text(level, format: .number)
                .echoFont(.caption, .semibold)
                .foregroundStyle(EchoColor.textOnAccent)
                .frame(width: 24, height: 24)
                .background(EchoColor.accent, in: Circle())
                .accessibilityHidden(true)
            Text(text)
                .echoFont(.supporting, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
        }
        .padding(.vertical, 6)
        .padding(.leading, 6)
        .padding(.trailing, EchoSpacing.m)
        .background(EchoColor.badgeSurface, in: Capsule())
        .overlay(Capsule().stroke(.white, lineWidth: 1))
        .echoShadow(.badge)
    }
}
