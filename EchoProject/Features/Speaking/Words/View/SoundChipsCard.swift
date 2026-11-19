import SwiftUI

/// "HEAR EACH SOUND" card from Words pronunciation help: one tappable chip per sound
/// ("S", "U", "N") and the how-to-say-it line underneath. The chip being spoken is
/// highlighted.
struct SoundChipsCard: View {
    let chips: [String]
    let hint: String
    let highlightedIndex: Int?
    let onTapChip: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: EchoSpacing.s) {
            Text("HEAR EACH SOUND")
                .echoFont(.caption, .semibold)
                .foregroundStyle(EchoColor.textSecondary)
            HStack(spacing: EchoSpacing.s) {
                ForEach(Array(chips.enumerated()), id: \.offset) { index, chip in
                    Button {
                        onTapChip(index)
                    } label: {
                        Text(chip)
                            .echoFont(.body, .semibold)
                            .foregroundStyle(EchoColor.textPrimary)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                highlightedIndex == index ? EchoColor.accent.opacity(0.25) : Color.white,
                                in: .rect(cornerRadius: 10)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Sound \(chip)")
                }
            }
            Text(hint)
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.speakingBody)
                .frame(maxWidth: .infinity)
        }
        .padding(EchoSpacing.m)
        .glassEffect(.regular, in: .rect(cornerRadius: EchoRadius.card))
    }
}

#Preview {
    SoundChipsCard(chips: ["S", "U", "N"], hint: "sss · uh · nnn → sun", highlightedIndex: 1, onTapChip: { _ in })
        .padding()
        .echoExerciseBackground()
}
