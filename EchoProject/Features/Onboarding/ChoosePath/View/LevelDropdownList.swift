import SwiftUI

/// The open dropdown: one row per level. Tapping a row picks it and closes the list.
struct LevelDropdownList: View {
    let levels: [LevelGuide]
    let onSelect: (LevelGuide) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(levels) { level in
                Button {
                    onSelect(level)
                } label: {
                    HStack(spacing: EchoSpacing.m) {
                        LevelNumberBadge(number: level.number)
                        Text(level.title)
                            .echoFont(.body)
                            .foregroundStyle(EchoColor.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, EchoSpacing.s)
                    .frame(height: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Level \(level.number), \(level.title)")
            }
        }
        .padding(EchoSpacing.s)
        .background(EchoColor.dropdownSurface, in: .rect(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.6), lineWidth: 1))
        .echoShadow(.dropdown)
    }
}
