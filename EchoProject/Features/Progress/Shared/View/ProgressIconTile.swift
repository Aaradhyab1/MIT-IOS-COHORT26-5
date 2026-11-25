import SwiftUI

/// A rounded square with an SF Symbol or short glyph on a soft background.
struct ProgressIconTile: View {
    enum Content {
        case symbol(String)
        case glyph(String)
    }

    let content: Content
    let accent: ProgressAccent
    var size: CGFloat = 36
    var cornerRadius: CGFloat = 10

    var body: some View {
        Group {
            switch content {
            case .symbol(let name): Image(systemName: name)
            case .glyph(let text): Text(text)
            }
        }
        .font(.headline)
        .foregroundStyle(ProgressPalette.accent(accent))
        .frame(width: size, height: size)
        .background(ProgressPalette.accentSoft(accent), in: .rect(cornerRadius: cornerRadius))
        .accessibilityHidden(true)
    }
}
