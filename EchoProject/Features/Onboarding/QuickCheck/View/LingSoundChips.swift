import SwiftUI

/// The six Ling sounds as round chips (question 6). Tap to mark the ones the child knows.
struct LingSoundChips: View {
    let choices: [String]
    let isSelected: (String) -> Bool
    let onToggle: (String) -> Void

    var body: some View {
        HStack(spacing: EchoSpacing.s) {
            ForEach(choices, id: \.self) { choice in
                let selected = isSelected(choice)
                Button(choice) {
                    onToggle(choice)
                }
                .echoFont(.supporting, .semibold)
                .foregroundStyle(selected ? EchoColor.textOnAccent : EchoColor.textTertiary)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(selected ? EchoColor.accent : .white.opacity(0.9), in: Capsule())
                .overlay(Capsule().stroke(selected ? .clear : EchoColor.fieldUnderline, lineWidth: 1))
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
    }
}
