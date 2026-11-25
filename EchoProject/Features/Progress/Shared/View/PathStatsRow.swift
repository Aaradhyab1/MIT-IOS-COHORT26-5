import SwiftUI

/// Three figures separated by thin dividers.
struct PathStatsRow: View {
    let stats: [ProgressPathStat]

    var body: some View {
        HStack(spacing: 14) {
            ForEach(stats) { stat in
                if stat.id != stats.first?.id {
                    Rectangle()
                        .fill(ProgressPalette.divider)
                        .frame(width: 1, height: 30)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(stat.value)
                        .font(.headline)
                        .foregroundStyle(ProgressPalette.textPrimary)
                    Text(stat.label)
                        .font(.footnote)
                        .foregroundStyle(ProgressPalette.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
            }
        }
    }
}
