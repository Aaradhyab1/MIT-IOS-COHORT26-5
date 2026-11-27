import SwiftUI

/// Echo on his grass mound in Listening home's Today's practice card.
/// Same transparent "Echo art" picture as the splash, at the card's 276 pt mound width.
struct EchoHeroArt: View {
    var body: some View {
        EchoAssetImage(name: "img_echo_art")
            .frame(width: 276, height: 175)
            .padding(.top, -4)   // Echo's ears sit just above the 156 pt art box in Figma
    }
}
