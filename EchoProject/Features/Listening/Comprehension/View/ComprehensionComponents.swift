import SwiftUI

enum ComprehensionColor {
    static let correct = Color(hex: 0x1E9E5A)
    static let incorrect = Color(hex: 0xE0383E)
    static let correctFill = Color(hex: 0xEAF8EF, opacity: 0.92)
    static let incorrectFill = Color(hex: 0xFDEEEF, opacity: 0.92)

    static let slotFill = Color.white.opacity(0.4)
    static let slotStroke = Color.white.opacity(0.85)
    static let slotBadge = Color(hex: 0xA1CCEB, opacity: 0.5)
    static let cardFill = Color.white.opacity(0.6)
    static let cardStroke = Color.white.opacity(0.96)
    static let dragHandle = Color(hex: 0x618CA3, opacity: 0.58)

    static let tileFill = Color(hex: 0xE3F7FF, opacity: 0.52)
    static let tileStroke = Color.white.opacity(0.9)

    static let howToPlayText = Color(hex: 0x004FA8)
    static let questionLabel = Color(hex: 0x122E4A)
    static let frostedCard = Color.white.opacity(0.58)
    static let frostedCardShadow = EchoShadow(color: Color(hex: 0x305285, opacity: 0.11), radius: 9, y: 6)

    static let listenIconFill = Color(hex: 0xE0F2FE)
    static let answerIconFill = Color(hex: 0xD1FAE5)
    static let answerIcon = Color(hex: 0x10B981)
}

enum ComprehensionLayout {
    static let questionTop: CGFloat = 24
    static let bottomButtonSideInset: CGFloat = 61
    static let bottomButtonBottomInset: CGFloat = 28
    static let orderingRowHeight: CGFloat = 75
    static let matchingTileHeight: CGFloat = 106
}

struct QuestionHeader: View {
    let title: String
    let subtitle: String
    var titleColor: Color = EchoColor.textPrimary
    var subtitleColor: Color = EchoColor.textSecondary

    var body: some View {
        VStack(spacing: EchoSpacing.xxs) {
            Text(title)
                .echoFont(.heading, .bold)
                .foregroundStyle(titleColor)
                .accessibilityAddTraits(.isHeader)
            Text(subtitle)
                .echoFont(.body)
                .foregroundStyle(subtitleColor)
            HowToPlayPill()
                .padding(.top, 22)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

struct HowToPlayPill: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("?")
                .echoFont(.caption, .semibold)
                .foregroundStyle(.white)
                .frame(width: 16, height: 16)
                .background(EchoColor.accentFill, in: .rect(cornerRadius: 8))
                .accessibilityHidden(true)
            Text("How to play")
                .echoFont(.caption, .semibold)
                .foregroundStyle(ComprehensionColor.howToPlayText)
        }
        .padding(.horizontal, EchoSpacing.m)
        .frame(height: 36)
        .background(Color.white.opacity(0.7), in: Capsule())
    }
}

struct ComprehensionBottomButton: View {
    let title: String
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.echoPrimary)
            .disabled(!isEnabled)
            .padding(.horizontal, ComprehensionLayout.bottomButtonSideInset)
            .padding(.bottom, ComprehensionLayout.bottomButtonBottomInset)
    }
}
