import SwiftUI

/// The current level's categories as round tiles with progress rings, spread across the row.
/// The first tile (today's category) is highlighted.
struct CategoryTilesRow: View {
    let groups: [PracticeGroup]
    let onSelect: (PracticeGroup) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(groups) { group in
                EchoCategoryTile(
                    title: group.title,
                    detail: group.detailText,
                    imageName: group.imageName,
                    progress: group.progressFraction,
                    isCurrent: group.id == groups.first?.id,
                    artworkOpacity: ListeningHomeStyle.artworkOpacity,
                    action: { onSelect(group) }
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, EchoSpacing.xs)
    }
}

/// Shared look for artwork on Listening home, so every picture on the screen matches.
enum ListeningHomeStyle {
    /// Artwork is softened very slightly so it sits calmly behind the text.
    static let artworkOpacity: Double = 0.9
}
