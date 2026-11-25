import SwiftUI

/// A weekday letter over a circle: ticked when practised, outlined for today.
struct WeekDayMarker: View {
    let day: ProgressWeekDay

    @ScaledMetric(relativeTo: .footnote) private var size: CGFloat = 32

    var body: some View {
        VStack(spacing: 6) {
            Text(day.letter)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(day.state == .today ? ProgressPalette.textPrimary : ProgressPalette.textSecondary)
            marker
                .frame(width: size, height: size)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.name)
        .accessibilityValue(accessibilityValue)
    }

    @ViewBuilder
    private var marker: some View {
        switch day.state {
        case .practiced:
            Circle()
                .fill(ProgressPalette.blue)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.white)
                }
        case .today:
            Circle()
                .fill(ProgressPalette.blue.opacity(0.12))
                .strokeBorder(ProgressPalette.blue, lineWidth: 2)
        case .missed, .upcoming:
            Circle()
                .fill(ProgressPalette.dayUpcoming)
        }
    }

    private var accessibilityValue: String {
        switch day.state {
        case .practiced: "Practised"
        case .missed: "Not practised"
        case .today: "Today"
        case .upcoming: "Coming up"
        }
    }
}
