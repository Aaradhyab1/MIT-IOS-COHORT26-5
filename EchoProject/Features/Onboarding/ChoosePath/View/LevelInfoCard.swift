import SwiftUI

/// One level in "The 4 levels": number, name, summary, icon, a paragraph and an example.
struct LevelInfoCard: View {
    let level: LevelGuide

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: EchoSpacing.m) {
                Text(level.number, format: .number)
                    .echoFont(.display, .bold)
                    .foregroundStyle(EchoColor.accent)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: EchoSpacing.xxs) {
                    Text(level.title)
                        .echoFont(.body, .semibold)
                        .foregroundStyle(EchoColor.textPrimary)
                        .accessibilityLabel("Level \(level.number), \(level.title)")
                    Text(level.summary)
                        .echoFont(.supporting)
                        .foregroundStyle(EchoColor.textSecondary)
                }
                Spacer(minLength: 0)
                Image(systemName: level.symbol)
                    .font(.system(size: 20))
                    .foregroundStyle(EchoColor.accent)
                    .frame(width: 44, height: 44)
                    .background(EchoColor.levelBadge, in: Circle())
                    .accessibilityHidden(true)
            }

            Text(level.detail)
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.textPrimary.opacity(0.85))

            VStack(alignment: .leading, spacing: EchoSpacing.xxs) {
                Text("For example")
                    .echoFont(.caption, .semibold)
                    .foregroundStyle(EchoColor.textSecondary)
                Text(level.example)
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(EchoColor.exampleSurface, in: .rect(cornerRadius: 14))
            .accessibilityElement(children: .combine)
        }
        .multilineTextAlignment(.leading)
        .padding(18)
        .background(EchoColor.infoCardSurface, in: .rect(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.95), lineWidth: 1))
    }
}
