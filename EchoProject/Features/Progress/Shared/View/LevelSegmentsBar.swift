import SwiftUI

/// One segment per level: full for finished levels, part-filled for the current one.
struct LevelSegmentsBar: View {
    let level: ProgressLevel
    let tint: Color

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...max(level.total, 1), id: \.self) { number in
                ProgressBar(value: fill(for: number), tint: tint)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Level \(level.number) of \(level.total)")
        .accessibilityValue(Text(level.completion, format: .percent.precision(.fractionLength(0))))
    }

    private func fill(for number: Int) -> Double {
        if number < level.number { return 1 }
        if number == level.number { return level.completion }
        return 0
    }
}
