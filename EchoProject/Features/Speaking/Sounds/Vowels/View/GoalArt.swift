import SwiftUI
import UIKit

/// The destination at the end of a sound friend's path.
///
/// Shows the goal's artwork once it's in Assets.xcassets. Until then it draws a native
/// stand-in (SF Symbols for the cloud and moon, a drawn wedge for the cheese), so the
/// path never shows a dashed placeholder.
struct GoalArt: View {
    let name: String

    var body: some View {
        if UIImage(named: name) != nil {
            EchoAssetImage(name: name)
        } else {
            standIn
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var standIn: some View {
        if name.hasSuffix("cloud") {
            symbol("cloud.fill", colors: [.white, EchoColor.Paper.lightBlue])
        } else if name.hasSuffix("moon") {
            symbol("moon.stars.fill", colors: [EchoColor.Paper.sunshine, EchoColor.Paper.sunshine.opacity(0.7)])
        } else if name.hasSuffix("cheese") {
            CheeseWedge()
                .padding(6)
        } else {
            symbol("star.fill", colors: [EchoColor.Paper.sunshine, EchoColor.Paper.sunshine])
        }
    }

    private func symbol(_ systemName: String, colors: [Color]) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .symbolRenderingMode(.palette)
            .foregroundStyle(colors[0], colors[1])
            .shadow(color: EchoColor.Paper.navy.opacity(0.15), radius: 3, y: 2)
            .padding(4)
    }
}

/// A soft yellow cheese wedge with a few holes, drawn with SwiftUI shapes.
private struct CheeseWedge: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack {
                WedgeShape()
                    .fill(EchoColor.Paper.sunshine)
                WedgeShape()
                    .stroke(Color(hex: 0xE0A93A), lineWidth: 2)
                Circle().fill(Color(hex: 0xEDB447)).frame(width: w * 0.16).position(x: w * 0.38, y: h * 0.62)
                Circle().fill(Color(hex: 0xEDB447)).frame(width: w * 0.10).position(x: w * 0.66, y: h * 0.74)
                Circle().fill(Color(hex: 0xEDB447)).frame(width: w * 0.09).position(x: w * 0.60, y: h * 0.48)
            }
            .shadow(color: EchoColor.Paper.navy.opacity(0.15), radius: 3, y: 2)
        }
        .aspectRatio(1.1, contentMode: .fit)
    }
}

private struct WedgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.42))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.30),
                          control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.05))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
