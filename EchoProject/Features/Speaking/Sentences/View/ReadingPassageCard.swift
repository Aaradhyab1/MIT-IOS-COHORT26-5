import SwiftUI

/// The white card with the passage, one tappable chip per word.
/// Figma: "Paragraph / Tap a word for pronunciation" (354 wide, 16 padding, 20 radius).
struct ReadingPassageCard: View {
    let words: [ReadingWord]
    let highlight: (ReadingWord) -> WordHighlight
    let onTapWord: (ReadingWord) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Tap any word to hear its pronunciation.")
                .echoFont(.supporting)
                .foregroundStyle(SentencesStyle.hint)
                .frame(minHeight: 32, alignment: .topLeading)

            WordFlowLayout(spacing: 2) {
                ForEach(words) { word in
                    WordChip(word: word, highlight: highlight(word)) { onTapWord(word) }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.8), in: .rect(cornerRadius: 20))
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.7)))
        .shadow(color: Color(hex: 0x0D2E1A, opacity: 0.16), radius: 12, y: 8)
    }
}

/// One word: 44 pt tall, 6 pt corners, green once read, blue while it is being read.
private struct WordChip: View {
    let word: ReadingWord
    let highlight: WordHighlight
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(word.text)
                .echoFont(.subheading)
                .foregroundStyle(EchoColor.textPrimary)
                .padding(.horizontal, 6)
                .frame(minWidth: 44, minHeight: 44)
                .background(fill, in: .rect(cornerRadius: 6))
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(word.text.trimmingCharacters(in: .punctuationCharacters))
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Hear how to say it")
    }

    private var fill: Color {
        switch highlight {
        case .none: .clear
        case .read: SentencesStyle.read
        case .current: SentencesStyle.current
        }
    }

    private var accessibilityValue: String {
        switch highlight {
        case .none: ""
        case .read: "Read"
        case .current: "Read this word now"
        }
    }
}

/// Lays words out left to right and wraps to a new line when the row is full,
/// like text in a book.
struct WordFlowLayout: Layout {
    var spacing: CGFloat = 2

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews, width: proposal.width ?? .infinity)
        let width = rows.map(\.width).max() ?? 0
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(subviews, width: bounds.width) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func arrange(_ subviews: Subviews, width maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var row = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let needed = row.indices.isEmpty ? size.width : row.width + spacing + size.width
            if needed > maxWidth, !row.indices.isEmpty {
                rows.append(row)
                row = Row()
            }
            row.width = row.indices.isEmpty ? size.width : row.width + spacing + size.width
            row.height = max(row.height, size.height)
            row.indices.append(index)
        }
        if !row.indices.isEmpty { rows.append(row) }
        return rows
    }
}

/// Colours from the Figma reading frames.
enum SentencesStyle {
    /// "Tap any word…" hint, #2563EB.
    static let hint = Color(hex: 0x2563EB)
    /// Words already read, #A3E6C1.
    static let read = Color(hex: 0xA3E6C1)
    /// The word being read now, #A8D4FF.
    static let current = Color(hex: 0xA8D4FF)
}
