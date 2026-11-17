import SwiftUI

extension View {
    /// Translucent white card with a hairline border and soft shadow.
    /// Used for exercise cards, skill cards and grouped content.
    func echoCard(cornerRadius: CGFloat = EchoRadius.card) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return background(EchoColor.cardSurface, in: shape)
            .overlay(shape.stroke(EchoColor.surfaceStroke, lineWidth: 1))
            .echoShadow(.card)
    }

    /// Large card that presents the recommended exercise at the top of Home.
    func echoHeroCard() -> some View {
        let shape = RoundedRectangle(cornerRadius: EchoRadius.hero, style: .continuous)
        return background(EchoColor.heroSurface, in: shape)
            .overlay(shape.stroke(EchoColor.surfaceStroke, lineWidth: 1))
            .echoShadow(.hero)
    }
}
