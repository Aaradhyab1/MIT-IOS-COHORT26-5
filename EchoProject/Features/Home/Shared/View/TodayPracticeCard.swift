import SwiftUI

/// The big card at the top of Home: level badge, the character on the grass,
/// the exercise name and line, time and count pills, and Start.
/// Figma: "Hero (single image)" in Home · Listening and Home · Speaking.
struct TodayPracticeCard<Art: View>: View {
    let practice: TodaysPractice
    let onStart: () -> Void
    @ViewBuilder let art: () -> Art

    var body: some View {
        VStack(spacing: 6) {
            art()
                .padding(.top, 62)
            Spacer(minLength: EchoSpacing.m)

            Text(practice.title)
                .echoFont(.display, .bold)
                .foregroundStyle(EchoColor.textPrimary)
            Text(practice.summary)
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.textTertiary)
                .padding(.top, EchoSpacing.xs)

            HStack(spacing: EchoSpacing.s) {
                EchoMetaPill(text: practice.minutesText, systemImage: "clock")
                EchoMetaPill(text: practice.countText)
            }
            .padding(.top, EchoSpacing.xs)

            Button("Start", action: onStart)
                .buttonStyle(.echoPrimary)
                .frame(maxWidth: 264)
                .padding(.top, EchoSpacing.xs)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, EchoSpacing.xl)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, minHeight: 478)
        .overlay(alignment: .topLeading) {
            EchoLevelBadge(level: practice.badgeNumber, text: practice.badgeText)
                .padding(.top, EchoSpacing.l)
                .padding(.leading, EchoSpacing.xl)
        }
        .echoHeroCard()
    }
}
