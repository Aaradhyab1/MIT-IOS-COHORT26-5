import SwiftUI

/// "Practise what you've learned": compact cards that scroll sideways, edge to edge.
struct ReviewCarousel: View {
    let groups: [PracticeGroup]
    let onSelect: (PracticeGroup) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: EchoSpacing.m) {
                ForEach(groups) { group in
                    EchoExerciseCard(title: group.title, meta: group.metaText,
                                     imageName: group.imageName,
                                     artworkOpacity: ListeningHomeStyle.artworkOpacity,
                                     action: { onSelect(group) })
                }
            }
            .padding(.top, EchoSpacing.xs)
            .padding(.bottom, 14)
        }
        .contentMargins(.horizontal, EchoSpacing.screenHorizontal, for: .scrollContent)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()   // card shadows aren't cut off
    }
}
