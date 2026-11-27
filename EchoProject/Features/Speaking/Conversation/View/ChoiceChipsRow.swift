import SwiftUI

/// The 2–3 choices the child can say, as white pills with a small picture slot each.
/// The choice the child said is outlined in blue.
struct ChoiceChipsRow: View {
    let choices: [ConversationChoice]
    var chosen: ConversationChoice? = nil

    var body: some View {
        HStack(spacing: EchoSpacing.s) {
            ForEach(choices) { choice in
                HStack(spacing: EchoSpacing.xs) {
                    ConversationImageSlot(imageName: choice.imageName)
                        .frame(width: 28, height: 28)
                    Text(choice.label)
                        .echoFont(.supporting, .semibold)
                        .foregroundStyle(EchoColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, EchoSpacing.m)
                .padding(.vertical, EchoSpacing.s)
                .background(EchoColor.pillSurface, in: Capsule())
                .overlay {
                    Capsule().stroke(EchoColor.accent, lineWidth: chosen == choice ? 2 : 0)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Choices: " + choices.map(\.label).joined(separator: ", "))
    }
}

#Preview {
    let choices = [
        ConversationChoice(id: "a", label: "Chocolate", imageName: nil),
        ConversationChoice(id: "b", label: "Vanilla", imageName: nil),
        ConversationChoice(id: "c", label: "Strawberry", imageName: nil)
    ]
    return ChoiceChipsRow(choices: choices, chosen: choices[0])
        .padding()
        .echoExerciseBackground(.iceCreamShop)
}
