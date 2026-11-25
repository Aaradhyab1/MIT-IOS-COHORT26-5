import SwiftUI

/// Rows of label + value separated by hairlines. `emphasis` picks which side is bold:
/// the value in blue ("2 points") or the label ("Level 1 · Detection").
struct ScoringRowList: View {
    enum Emphasis {
        case label
        case value
    }

    let rows: [ScoringRow]
    let emphasis: Emphasis

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                HStack {
                    Text(row.label)
                        .echoFont(.caption, emphasis == .label ? .semibold : .regular)
                        .foregroundStyle(EchoColor.textPrimary)
                    Spacer()
                    Text(row.value)
                        .echoFont(.caption, emphasis == .value ? .semibold : .regular)
                        .foregroundStyle(emphasis == .value ? EchoColor.accent : EchoColor.textSecondary)
                }
                .frame(minHeight: 44)
                .accessibilityElement(children: .combine)

                if row.id != rows.last?.id {
                    Rectangle()
                        .fill(EchoColor.sheetDivider)
                        .frame(height: 1)
                }
            }
        }
    }
}
