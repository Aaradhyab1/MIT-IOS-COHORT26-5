import SwiftUI

/// The solid white card used for charts and lists.
struct ProgressPlainCard<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ProgressPalette.card, in: .rect(cornerRadius: 20))
            .shadow(color: ProgressPalette.cardShadow, radius: 8, y: 4)
    }
}
