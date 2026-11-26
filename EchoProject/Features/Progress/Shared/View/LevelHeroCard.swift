import SwiftUI

/// "Right now" hero on a path screen: current level, a short note, a ring and a level chip.
struct LevelHeroCard: View {
    let track: ProgressTrack
    let level: ProgressLevel
    let chipText: String

    var body: some View {
        ProgressGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("RIGHT NOW")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(ProgressPalette.tintText(track))
                        Text(level.name)
                            .font(.title.bold())
                            .foregroundStyle(ProgressPalette.textPrimary)
                        Text(level.detail)
                            .font(.subheadline)
                            .foregroundStyle(ProgressPalette.textSecondary)
                    }
                    .accessibilityElement(children: .combine)

                    Spacer(minLength: 0)

                    LevelRingChart(completion: level.completion, tint: ProgressPalette.tint(track))
                }

                Text(chipText)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(ProgressPalette.tintText(track))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(ProgressPalette.tint(track).opacity(0.12), in: .capsule)
            }
        }
    }
}
