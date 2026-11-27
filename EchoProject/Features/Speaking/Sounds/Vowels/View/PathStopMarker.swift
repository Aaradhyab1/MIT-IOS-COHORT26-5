import SwiftUI

/// A stop on the sound path: empty circle, yellow star, or a gentle coral "try again" ring.
struct PathStopMarker: View {
    let stop: PathStop

    var body: some View {
        ZStack {
            Circle()
                .fill(fill)
            Circle()
                .strokeBorder(stroke, style: StrokeStyle(lineWidth: 3, dash: stop == .tryAgain ? [5, 4] : []))
            switch stop {
            case .reached:
                Image(systemName: "star.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(EchoColor.soundsStar)
            case .tryAgain:
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(EchoColor.soundsRetry)
            case .waiting:
                EmptyView()
            }
        }
        .frame(width: 34, height: 34)
        .accessibilityHidden(true)
    }

    private var fill: Color {
        stop == .tryAgain ? EchoColor.soundsRetrySurface : .white
    }

    private var stroke: Color {
        switch stop {
        case .waiting: EchoColor.ringTrack
        case .reached: EchoColor.soundsStar
        case .tryAgain: EchoColor.soundsRetry
        }
    }
}

#Preview {
    HStack {
        PathStopMarker(stop: .waiting)
        PathStopMarker(stop: .reached)
        PathStopMarker(stop: .tryAgain)
    }
    .padding()
    .echoScreenBackground()
}
