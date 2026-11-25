import Charts
import SwiftUI

/// "Accuracy this week": a Swift Charts line and area chart with a callout on the latest day.
struct AccuracyChartCard: View {
    let weeklyAccuracy: Double
    let change: Double
    let days: [ProgressDayValue]
    let latestDayId: Int?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isRevealed = false

    private let tint = ProgressPalette.blue
    private let floor = 0.6

    var body: some View {
        ProgressPlainCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Accuracy this week")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(ProgressPalette.textSecondary)
                        Text(weeklyAccuracy, format: .percent.precision(.fractionLength(0)))
                            .font(.largeTitle.bold())
                            .foregroundStyle(ProgressPalette.textPrimary)
                    }
                    .accessibilityElement(children: .combine)
                    Spacer(minLength: 8)
                    TrendChip(change: change)
                }

                chart
                    .frame(height: 150)
            }
        }
        .onAppear {
            if reduceMotion {
                isRevealed = true
            } else {
                withAnimation(.easeOut(duration: 0.6)) { isRevealed = true }
            }
        }
    }

    private var scored: [ProgressDayValue] {
        days.filter { $0.value != nil }
    }

    private func shown(_ value: Double) -> Double {
        isRevealed ? value : floor
    }

    private var chart: some View {
        Chart {
            ForEach(scored) { day in
                let value = shown(day.value ?? floor)

                AreaMark(
                    x: .value("Day", Double(day.id)),
                    yStart: .value("Floor", floor),
                    yEnd: .value("Accuracy", value)
                )
                .foregroundStyle(
                    LinearGradient(colors: [tint.opacity(0.28), tint.opacity(0.02)], startPoint: .top, endPoint: .bottom)
                )

                LineMark(x: .value("Day", Double(day.id)), y: .value("Accuracy", value))
                    .foregroundStyle(tint)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                PointMark(x: .value("Day", Double(day.id)), y: .value("Accuracy", value))
                    .symbol {
                        let isLatest = day.id == latestDayId
                        Circle()
                            .fill(isLatest ? tint : .white)
                            .strokeBorder(isLatest ? .white : tint, lineWidth: isLatest ? 3 : 2.5)
                            .frame(width: isLatest ? 14 : 9, height: isLatest ? 14 : 9)
                    }
                    .annotation(position: .top, spacing: 6) {
                        if day.id == latestDayId, let accuracy = day.value {
                            Text(accuracy, format: .percent.precision(.fractionLength(0)))
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(tint, in: .capsule)
                                .opacity(isRevealed ? 1 : 0)
                        }
                    }
                    .accessibilityLabel(day.name)
                    .accessibilityValue(Text(day.value ?? 0, format: .percent.precision(.fractionLength(0))))
            }
        }
        .chartXScale(domain: -0.5...(Double(days.count) - 0.5))
        .chartYScale(domain: floor...1.0)
        .chartXAxis {
            AxisMarks(values: days.map { Double($0.id) }) { value in
                if let position = value.as(Double.self), let day = days.first(where: { Double($0.id) == position }) {
                    AxisValueLabel {
                        Text(day.letter)
                            .font(day.isToday ? .footnote.weight(.semibold) : .footnote)
                            .foregroundStyle(day.isToday ? ProgressPalette.textPrimary : ProgressPalette.textSecondary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [0.6, 0.8, 1.0]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(ProgressPalette.divider)
                AxisValueLabel {
                    if let percent = value.as(Double.self) {
                        Text(percent, format: .percent.precision(.fractionLength(0)))
                            .font(.footnote)
                            .foregroundStyle(ProgressPalette.textSecondary)
                    }
                }
            }
        }
    }
}
