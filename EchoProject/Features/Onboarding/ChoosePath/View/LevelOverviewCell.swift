import SwiftUI

/// One level in the overview: big number, icon, name and a one-line summary.
struct LevelOverviewCell: View {
    let level: LevelGuide

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(level.number, format: .number)
                    .echoFont(.display, .bold)
                    .foregroundStyle(EchoColor.accent)
                Spacer()
                Image(systemName: level.symbol)
                    .font(.system(size: 22))
                    .foregroundStyle(EchoColor.accent)
                    .accessibilityHidden(true)
            }
            Text(level.title)
                .echoFont(.body, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.top, EchoSpacing.m)
            Text(level.summary)
                .echoFont(.caption)
                .foregroundStyle(EchoColor.textSecondary)
                .padding(.top, EchoSpacing.xs)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal, EchoSpacing.l)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Level \(level.number), \(level.title). \(level.summary)")
    }
}
