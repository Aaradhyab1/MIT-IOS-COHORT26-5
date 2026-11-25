import SwiftUI

/// The 4 levels at a glance, 2 × 2 with hairlines between them. Information only, not tappable.
/// Figma: "Level overview (information, not tappable)".
struct LevelOverviewGrid: View {
    let levels: [LevelGuide]

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                cell(at: 0)
                verticalDivider
                cell(at: 1)
            }
            Rectangle()
                .fill(EchoColor.gridDivider)
                .frame(height: 1)
                .gridCellUnsizedAxes(.horizontal)
                .padding(.horizontal, EchoSpacing.l)
            GridRow {
                cell(at: 2)
                verticalDivider
                cell(at: 3)
            }
        }
        .background(EchoColor.overviewSurface, in: .rect(cornerRadius: EchoRadius.cardLarge))
        .overlay {
            RoundedRectangle(cornerRadius: EchoRadius.cardLarge)
                .stroke(.white.opacity(0.9), lineWidth: 1)
        }
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(EchoColor.gridDivider)
            .frame(width: 1)
            .gridCellUnsizedAxes(.vertical)
            .padding(.vertical, EchoSpacing.l)
    }

    @ViewBuilder
    private func cell(at index: Int) -> some View {
        if levels.indices.contains(index) {
            LevelOverviewCell(level: levels[index])
        } else {
            Color.clear
        }
    }
}
