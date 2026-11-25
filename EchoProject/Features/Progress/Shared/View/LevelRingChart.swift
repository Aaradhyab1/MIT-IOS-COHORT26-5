import Charts
import SwiftUI

/// A donut chart (Swift Charts `SectorMark`) showing how far through the level the child is.
struct LevelRingChart: View {
    let completion: Double
    let tint: Color

    @ScaledMetric(relativeTo: .title3) private var size: CGFloat = 80

    var body: some View {
        Chart {
            SectorMark(angle: .value("Done", completion), innerRadius: .ratio(0.76))
                .foregroundStyle(tint)
                .cornerRadius(4)
            SectorMark(angle: .value("To go", max(1 - completion, 0)), innerRadius: .ratio(0.76))
                .foregroundStyle(tint.opacity(0.18))
        }
        .chartLegend(.hidden)
        .frame(width: size, height: size)
        .overlay {
            Text(completion, format: .percent.precision(.fractionLength(0)))
                .font(.title3.bold())
                .foregroundStyle(ProgressPalette.textPrimary)
                .minimumScaleFactor(0.6)
                .padding(size * 0.2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Level progress")
        .accessibilityValue(Text(completion, format: .percent.precision(.fractionLength(0))))
    }
}
