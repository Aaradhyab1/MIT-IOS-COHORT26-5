import SwiftUI

/// "Recommended starting level": the step row, then the level with its icon and one line about it.
struct RecommendationCard: View {
    let recommendation: LevelRecommendation
    let levelCount: Int
    let revealedStep: Int
    let progressDescription: String

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recommended starting level")
                .echoFont(.body, .semibold)
                .foregroundStyle(EchoColor.textPrimary)

            LevelStepRow(levelCount: levelCount, revealedStep: revealedStep)
                .padding(.horizontal, EchoSpacing.m)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(progressDescription)

            HStack(spacing: EchoSpacing.m) {
                Image(systemName: recommendation.symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(EchoColor.accent)
                    .frame(width: 54, height: 54)
                    .background(EchoColor.symbolTile, in: .rect(cornerRadius: 14))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: EchoSpacing.xs) {
                    Text(recommendation.heading)
                        .echoFont(.supporting, .semibold)
                        .foregroundStyle(EchoColor.textPrimary)
                    Text(recommendation.blurb)
                        .echoFont(.supporting)
                        .foregroundStyle(EchoColor.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .padding(EchoSpacing.m)
            .background(EchoColor.innerSurface, in: .rect(cornerRadius: 20))
            .accessibilityElement(children: .combine)
        }
        .multilineTextAlignment(.leading)
        .padding(EchoSpacing.l)
        .echoCard()
    }
}
