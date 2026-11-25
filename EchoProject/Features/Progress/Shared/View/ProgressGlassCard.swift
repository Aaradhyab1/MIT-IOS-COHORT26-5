import SwiftUI

/// The frosted Liquid Glass hero card used at the top of each Progress screen.
struct ProgressGlassCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(21)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular.tint(.white.opacity(0.35)), in: .rect(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(ProgressPalette.glassStroke, lineWidth: 1)
            }
            .shadow(color: ProgressPalette.glassShadow, radius: 12, y: 8)
    }
}
