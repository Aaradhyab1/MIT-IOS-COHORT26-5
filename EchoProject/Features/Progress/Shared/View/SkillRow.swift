import SwiftUI

/// A skill with its icon, status, score and a progress bar underneath.
struct SkillRow: View {
    let skill: ProgressSkill
    let tint: Color

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                ProgressIconTile(content: .symbol(skill.symbol), accent: skill.accent)
                VStack(alignment: .leading, spacing: 0) {
                    Text(skill.name)
                        .font(.headline)
                        .foregroundStyle(ProgressPalette.textPrimary)
                    Text(skill.status.title)
                        .font(skill.status == .goingStrong ? .footnote.weight(.semibold) : .footnote)
                        .foregroundStyle(skill.status == .goingStrong ? ProgressPalette.greenText : ProgressPalette.textSecondary)
                }
                Spacer(minLength: 8)
                Text(skill.score, format: .percent.precision(.fractionLength(0)))
                    .font(.headline.bold())
                    .foregroundStyle(ProgressPalette.textPrimary)
            }
            ProgressBar(value: skill.score, tint: tint)
        }
        .accessibilityElement(children: .combine)
    }
}
