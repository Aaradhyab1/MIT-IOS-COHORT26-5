import SwiftUI

/// "This week" hero: streak chip, number of sessions and one marker per day.
struct WeekStreakCard: View {
    let week: ProgressWeekSummary
    let streakText: String
    let sessionsText: String

    var body: some View {
        ProgressGlassCard {
            VStack(alignment: .leading, spacing: 18) {
                Label(streakText, systemImage: "flame.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(ProgressPalette.streakText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(ProgressPalette.streakFill, in: .capsule)

                Text(sessionsText)
                    .font(.title.bold())
                    .foregroundStyle(ProgressPalette.textPrimary)

                HStack(spacing: 0) {
                    ForEach(week.days) { day in
                        if day.id != week.days.first?.id {
                            Spacer(minLength: 4)
                        }
                        WeekDayMarker(day: day)
                    }
                }
            }
        }
    }
}
