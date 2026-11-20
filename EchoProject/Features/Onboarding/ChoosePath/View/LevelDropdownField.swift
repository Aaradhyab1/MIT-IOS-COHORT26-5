import SwiftUI

/// The dropdown's field: "Choose a level", or the picked level with its number.
/// The chevron points up while the list is open.
struct LevelDropdownField: View {
    let selected: LevelGuide?
    let isOpen: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: EchoSpacing.m) {
                if let selected {
                    LevelNumberBadge(number: selected.number)
                    Text(selected.title)
                        .foregroundStyle(EchoColor.textPrimary)
                } else {
                    Text("Choose a level")
                        .foregroundStyle(EchoColor.textSecondary)
                }
                Spacer()
                Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(EchoColor.textSecondary)
            }
            .echoFont(.body)
            .padding(.horizontal, EchoSpacing.l)
            .frame(height: 56)
            .background(EchoColor.overlayControl, in: .rect(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.6), lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Starting level")
        .accessibilityValue(selected?.title ?? "None chosen")
        .accessibilityHint(isOpen ? "Hides the levels" : "Shows the levels")
    }
}
