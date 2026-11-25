import SwiftUI

/// A rounded bar that fills from the left.
struct ProgressBar: View {
    let value: Double
    let tint: Color
    var height: CGFloat = 8
    var track: Color = ProgressPalette.track

    var body: some View {
        Capsule()
            .fill(track)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(tint)
                        .frame(width: proxy.size.width * min(max(value, 0), 1))
                }
            }
            .clipShape(.capsule)
            .frame(height: height)
            .accessibilityHidden(true)
    }
}
