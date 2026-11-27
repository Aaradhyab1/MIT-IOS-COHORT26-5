import SwiftUI

/// The friend on its path to the goal, with two stops on the way.
///
/// The solid trail grows behind the friend; the rest of the way is dashed.
/// Figma: "Sounds v2 / Plane · Your turn · …".
struct SoundPathView: View {
    let stops: [PathStop]
    /// 0 at the start, 1 at the goal.
    let progress: Double
    let travelImage: String
    let goalImage: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let friendPoint = SoundPathCurve.point(at: progress, in: size)
            let goalPoint = SoundPathCurve.point(at: 1, in: size)
            let friendSize = size.height * 0.62

            ZStack(alignment: .topLeading) {
                SoundPathShape()
                    .stroke(EchoColor.ringTrack, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 10]))
                SoundPathShape()
                    .trim(from: 0, to: progress)
                    .stroke(EchoColor.accentFill, style: StrokeStyle(lineWidth: 6, lineCap: .round))

                EchoAssetImage(name: goalImage)
                    .frame(width: size.height * 0.5, height: size.height * 0.5)
                    .position(x: goalPoint.x + size.height * 0.12, y: goalPoint.y - size.height * 0.2)

                ForEach(Array(stops.enumerated()), id: \.offset) { index, stop in
                    let point = SoundPathCurve.point(at: Double(index + 1) / Double(stops.count + 1), in: size)
                    PathStopMarker(stop: stop)
                        .position(point)
                    if stop == .tryAgain {
                        TryAgainTag()
                            .position(x: point.x, y: point.y + 34)
                    }
                }

                EchoAssetImage(name: travelImage)
                    .frame(width: friendSize, height: friendSize)
                    .position(x: friendPoint.x, y: friendPoint.y - friendSize * 0.32)
            }
            .animation(reduceMotion ? nil : .spring(duration: 0.7, bounce: 0.25), value: progress)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        let reached = stops.filter { $0 == .reached }.count + (progress >= 1 ? 1 : 0)
        return "\(reached) of \(stops.count + 1) stops reached"
    }
}

#Preview {
    SoundPathView(stops: [.reached, .tryAgain], progress: 1.0 / 3.0,
                  travelImage: "img_vowel_plane_travel", goalImage: "img_vowel_goal_cloud")
        .frame(height: 200)
        .padding()
        .echoExerciseBackground()
}
