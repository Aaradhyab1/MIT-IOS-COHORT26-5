import SwiftUI

/// "Your speech skills": Sounds, Words and Sentences as compact cards scrolling sideways.
struct SkillCarousel: View {
    let cards: [SkillCard]
    let onSelect: (SkillCard) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: EchoSpacing.m) {
                ForEach(cards) { card in
                    EchoExerciseCard(title: card.title, meta: card.meta,
                                     imageName: card.imageName, action: { onSelect(card) })
                }
            }
            .padding(.top, EchoSpacing.xs)
            .padding(.bottom, 14)
        }
        .contentMargins(.horizontal, EchoSpacing.screenHorizontal, for: .scrollContent)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }
}
