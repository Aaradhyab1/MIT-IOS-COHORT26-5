import SwiftUI

/// A Listening or Speaking card on the overview. Tapping it opens that path's details.
struct LearningPathCard: View {
    let path: ProgressPathSummary
    let levelLine: String
    let completedLine: String

    @ScaledMetric(relativeTo: .headline) private var tileSize: CGFloat = 48

    private var tint: Color { ProgressPalette.tint(path.track) }

    var body: some View {
        ProgressGlassCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    Image(systemName: path.track.symbol)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: tileSize, height: tileSize)
                        .background(ProgressPalette.iconGradient(path.track), in: .rect(cornerRadius: 14))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(path.track.title)
                            .font(.headline)
                            .foregroundStyle(ProgressPalette.textPrimary)
                        Text(levelLine)
                            .font(.subheadline)
                            .foregroundStyle(ProgressPalette.textSecondary)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }

                VStack(spacing: 8) {
                    LevelSegmentsBar(level: path.level, tint: tint)
                    HStack {
                        Text(completedLine)
                            .font(.subheadline)
                            .foregroundStyle(ProgressPalette.textSecondary)
                        Spacer()
                        Text(path.level.completion, format: .percent.precision(.fractionLength(0)))
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(ProgressPalette.tintText(path.track))
                    }
                }

                Rectangle()
                    .fill(ProgressPalette.hairline)
                    .frame(height: 1)

                PathStatsRow(stats: path.stats)
            }
        }
        .contentShape(.rect(cornerRadius: 24))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Shows \(path.track.title.lowercased()) progress")
    }
}
