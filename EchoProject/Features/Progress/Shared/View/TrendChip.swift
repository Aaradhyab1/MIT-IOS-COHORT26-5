import SwiftUI

/// "↗ 6% vs last week" pill.
struct TrendChip: View {
    let change: Double

    private var isUp: Bool { change >= 0 }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                .font(.caption.weight(.bold))
                .accessibilityHidden(true)
            Text("\(abs(change).formatted(.percent.precision(.fractionLength(0)))) vs last week")
                .font(.footnote.weight(.semibold))
        }
        .foregroundStyle(isUp ? ProgressPalette.greenText : ProgressPalette.streakText)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isUp ? ProgressPalette.greenSoft : ProgressPalette.streakFill, in: .capsule)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(isUp ? "Up" : "Down") \(abs(change).formatted(.percent.precision(.fractionLength(0)))) compared with last week")
    }
}
