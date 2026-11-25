import Charts
import SwiftUI

/// "New words this week": total, a small Swift Charts bar chart per day, and example words.
struct NewWordsCard: View {
    let total: Int
    let days: [ProgressDayValue]
    let examples: [String]
    let bestDayId: Int?

    private let accents: [ProgressAccent] = [.blue, .green, .purple]

    var body: some View {
        ProgressPlainCard {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("New words this week")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ProgressPalette.textSecondary)
                    Text(total, format: .number)
                        .font(.largeTitle.bold())
                        .foregroundStyle(ProgressPalette.textPrimary)
                }
                .accessibilityElement(children: .combine)

                chart
                    .frame(height: 96)

                Text("New words learnt")
                    .font(.subheadline)
                    .foregroundStyle(ProgressPalette.textSecondary)

                HStack(spacing: 14) {
                    ForEach(Array(examples.enumerated()), id: \.offset) { index, word in
                        let accent = accents[index % accents.count]
                        Text(word)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(ProgressPalette.accent(accent))
                            .frame(maxWidth: .infinity, minHeight: 42)
                            .background(ProgressPalette.accentSoft(accent), in: .rect(cornerRadius: 14))
                    }
                }

                Text("Every new word adds another way to share.")
                    .font(.subheadline)
                    .foregroundStyle(ProgressPalette.textSecondary)
            }
        }
    }

    private var chart: some View {
        Chart(days) { day in
            BarMark(
                x: .value("Day", day.letter + String(day.id)),
                y: .value("Words", day.value ?? 0),
                width: .ratio(0.55)
            )
            .foregroundStyle(day.id == bestDayId ? ProgressPalette.green : ProgressPalette.green.opacity(0.35))
            .cornerRadius(5)
            .accessibilityLabel(day.name)
            .accessibilityValue(day.value.map { "\(Int($0)) new words" } ?? "Coming up")
        }
        .chartXAxis {
            AxisMarks { value in
                if let key = value.as(String.self), let day = days.first(where: { $0.letter + String($0.id) == key }) {
                    AxisValueLabel {
                        Text(day.letter)
                            .font(day.isToday ? .footnote.weight(.semibold) : .footnote)
                            .foregroundStyle(day.isToday ? ProgressPalette.textPrimary : ProgressPalette.textSecondary)
                    }
                }
            }
        }
        .chartYAxis(.hidden)
    }
}
