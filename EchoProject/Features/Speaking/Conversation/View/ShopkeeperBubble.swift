import SwiftUI

/// White speech bubble with "SHOPKEEPER" and what they say, plus a speaker button to
/// hear it again. Figma: "Role Play / Dialogue" with its tail (254 pt wide, radius 26).
struct ShopkeeperBubble: View {
    let line: String
    let onHearAgain: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: EchoSpacing.s) {
                VStack(alignment: .leading, spacing: EchoSpacing.xs) {
                    Text("SHOPKEEPER")
                        .echoFont(.caption, .semibold)
                        .foregroundStyle(EchoColor.textSecondary)
                    Text(line)
                        .echoFont(.body, .bold)
                        .foregroundStyle(EchoColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Button("Hear again", systemImage: "speaker.wave.2.fill", action: onHearAgain)
                    .labelStyle(.iconOnly)
                    .foregroundStyle(EchoColor.accent)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .padding(.leading, EchoSpacing.l)
            .padding(.vertical, EchoSpacing.m)
            .padding(.trailing, EchoSpacing.xs)
            .background(.white, in: .rect(cornerRadius: 26))
            .echoShadow(.card)

            // Tail pointing down at the shopkeeper.
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 22))
                .foregroundStyle(.white)
                .offset(y: -8)
                .padding(.leading, 90)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: 300, alignment: .leading)
    }
}

#Preview {
    ShopkeeperBubble(line: "Hi there! What ice cream would you like today?", onHearAgain: {})
        .padding()
        .echoExerciseBackground(.iceCreamShop)
}
