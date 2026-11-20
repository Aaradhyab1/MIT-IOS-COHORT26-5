import SwiftUI

/// Often / Sometimes / Never as three separate buttons.
/// Each is a white pill with a hairline border and a soft shadow, so it reads as tappable;
/// the chosen one turns blue. Same look as the Ling-sound chips.
struct AnswerOptions: View {
    let options: [QuickCheckAnswer]
    let selected: QuickCheckAnswer?
    let label: (QuickCheckAnswer) -> String
    let onSelect: (QuickCheckAnswer) -> Void

    var body: some View {
        HStack(spacing: EchoSpacing.s) {
            ForEach(options, id: \.self) { option in
                Button(label(option)) {
                    onSelect(option)
                }
                .buttonStyle(AnswerOptionButtonStyle(isSelected: option == selected))
                .accessibilityAddTraits(option == selected ? .isSelected : [])
            }
        }
    }
}
