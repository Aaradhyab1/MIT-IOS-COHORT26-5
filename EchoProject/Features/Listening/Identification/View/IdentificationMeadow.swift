import SwiftUI

/// The meadow every Identification screen stands on, shared by the learning step
/// (LearnSoundsView) and the game (PictureChoiceView).
///
/// Content is laid out in the 402 × 874 Figma frame (top-left origin) and the whole
/// canvas is scaled to fill the screen, so the pictures stay on the grass on every iPhone.
struct MeadowCanvas<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { geo in
            let canvas = IdentificationScene.canvasSize
            let scale = max(geo.size.width / canvas.width, geo.size.height / canvas.height)

            ZStack(alignment: .topLeading) {
                RaisedMeadowBackground()
                content()
            }
            .frame(width: canvas.width, height: canvas.height, alignment: .topLeading)
            .scaleEffect(scale)
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .clipped()
        .ignoresSafeArea()
    }
}

extension View {
    /// Sizes and places a view at a rectangle of the Figma frame, inside a MeadowCanvas.
    func placed(in rect: CGRect) -> some View {
        frame(width: rect.width, height: rect.height)
            .offset(x: rect.minX, y: rect.minY)
    }
}

// MARK: - Pieces of the meadow

/// What a picture stands on: a cream mat (instruments) or a soft shadow (animals).
struct GroundView: View {
    let ground: IdentificationScene.Ground

    var body: some View {
        switch ground {
        case .mat(let rect):
            MatView().placed(in: rect)
        case .shadow(let rect):
            Ellipse()
                .fill(Color(hex: 0x0A2B14, opacity: 0.38))
                .blur(radius: 5)
                .placed(in: rect)
                .accessibilityHidden(true)
        }
    }
}

/// The shared landscape with its green hills raised, so all four mats stand on the grass.
/// A second, larger copy of the same picture is faded in below the sky; the clouds at
/// the top and the flowers at the bottom still come from the normal picture.
/// Figma: "Background · raised meadow (same image)".
struct RaisedMeadowBackground: View {
    private let canvas = IdentificationScene.canvasSize

    var body: some View {
        ZStack(alignment: .topLeading) {
            landscape(width: canvas.width, height: canvas.height)

            landscape(width: 562.8, height: 1223.6)
                .offset(x: -50, y: -347)
                .frame(width: canvas.width, height: canvas.height, alignment: .topLeading)
                .clipped()
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .clear, location: 0.412),
                            .init(color: .black, location: 0.481),
                            .init(color: .black, location: 0.80),
                            .init(color: .clear, location: 0.845),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
        .accessibilityHidden(true)
    }

    private func landscape(width: CGFloat, height: CGFloat) -> some View {
        Image("img_bg_landscape")
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipped()
    }
}

/// Cream mat with a dashed coral ring that each picture stands on (Figma "Mat").
struct MatView: View {
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .top) {
                Ellipse()
                    .fill(Color(hex: 0xE9CBA6))
                    .frame(width: width - 2, height: 30)
                    .padding(.top, 3)
                Ellipse()
                    .fill(Color(hex: 0xFFF3E0))
                    .frame(width: width - 4, height: 28)
                    .padding(.top, 1)
                Ellipse()
                    .stroke(Color(hex: 0xF4B9A2), style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
                    .frame(width: width - 24, height: 18)
                    .padding(.top, 6)
            }
            .frame(width: width)
        }
        .accessibilityHidden(true)
    }
}

/// Red or green outline that follows the picture's own shape: the picture drawn
/// in one colour, nudged 3 points in eight directions, behind the real picture.
struct OutlineBehind: View {
    let art: String
    let color: Color

    private let offsets: [CGSize] = [
        CGSize(width: 3, height: 0), CGSize(width: -3, height: 0),
        CGSize(width: 0, height: 3), CGSize(width: 0, height: -3),
        CGSize(width: 2, height: 2), CGSize(width: -2, height: 2),
        CGSize(width: 2, height: -2), CGSize(width: -2, height: -2)
    ]

    var body: some View {
        ZStack {
            ForEach(offsets.indices, id: \.self) { index in
                Image(art)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundStyle(color)
                    .offset(offsets[index])
            }
        }
        .transition(.opacity)
        .accessibilityHidden(true)
    }
}
