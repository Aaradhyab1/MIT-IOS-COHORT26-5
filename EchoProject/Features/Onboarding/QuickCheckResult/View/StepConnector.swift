import SwiftUI

/// The line between two steps; fills blue from the left.
struct StepConnector: View {
    let isFilled: Bool

    var body: some View {
        Capsule()
            .fill(EchoColor.stepTrack)
            .frame(height: 4)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(EchoColor.accent)
                    .scaleEffect(x: isFilled ? 1 : 0, anchor: .leading)
            }
            .padding(.horizontal, 4)
    }
}
