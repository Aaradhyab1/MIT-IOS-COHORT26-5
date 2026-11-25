import SwiftUI
import UIKit

/// An image from the asset catalog that shows a dashed placeholder, labelled with the
/// asset name, until the artwork is added. Drop a file with that name into
/// Assets.xcassets and it replaces the placeholder with no code change.
///
///     EchoAssetImage(name: "img_grass_mound")
struct EchoAssetImage: View {
    let name: String

    var body: some View {
        if UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)
        } else {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(EchoColor.ringTrack, style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                .overlay {
                    Text(name)
                        .echoFont(.caption)
                        .foregroundStyle(EchoColor.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(4)
                }
                .accessibilityHidden(true)
        }
    }
}

/// A character standing on the grass mound shared by the splash, onboarding and Home.
///
/// Layers, back to front: the mound with bushes, the character, a strip of grass over
/// their feet. Every size and position is a fraction of `size`, taken from the Figma
/// "Echo art" frame, so the scene looks the same at any size.
///
///     EchoGrassStage(size: 210) {
///         EchoAssetImage(name: "img_echo_hero")
///     }
struct EchoGrassStage<Character: View>: View {
    /// Width and height of the square the character stands in.
    let size: CGFloat
    /// Character size as a multiple of `size`.
    var characterScale: CGFloat = 1.064
    /// Character top edge as a fraction of `size` (negative = above the square).
    var characterTop: CGFloat = -0.029
    var showsFrontGrass = true
    @ViewBuilder let character: () -> Character

    var body: some View {
        ZStack(alignment: .topLeading) {
            EchoAssetImage(name: "img_grass_mound")
                .frame(width: size * 1.769, height: size * 0.897)
                .offset(x: size * -0.385, y: size * 0.192)

            character()
                .frame(width: size * characterScale, height: size * characterScale)
                .offset(x: size * (1 - characterScale) / 2, y: size * characterTop)

            EchoAssetImage(name: "img_grass_strip")
                .frame(width: size * 0.769, height: size * 0.154)
                .offset(x: size * 0.077, y: size * 0.821)
                .opacity(showsFrontGrass ? 1 : 0)
        }
        .frame(width: size, height: size, alignment: .topLeading)
    }
}

extension View {
    /// Softens the edges into a circle, like the "Feather mask" on Echo's video in Figma.
    func echoFeatheredCircle() -> some View {
        mask {
            // Fractions of the view's size: solid to 78 % of the radius, then fades out.
            EllipticalGradient(
                stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: 0.78),
                    .init(color: .clear, location: 1)
                ],
                center: .center,
                startRadiusFraction: 0,
                endRadiusFraction: 0.5
            )
        }
    }
}

#Preview("Grass stage") {
    EchoGrassStage(size: 210) {
        EchoAssetImage(name: "img_echo_hero")
    }
    .padding(100)
    .echoScreenBackground()
}
