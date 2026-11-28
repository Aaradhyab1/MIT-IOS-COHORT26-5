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
    /// Measured width of the "Try this one again" tag, so it can sit clear of the friend.
    @State private var tagWidth: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let friendSize = Self.friendSize(in: size)
            let startX = Self.startX(friendSize: friendSize, width: size.width)
            let friendPoint = SoundPathCurve.point(at: progress, in: size, startX: startX)
            let goalPoint = SoundPathCurve.point(at: 1, in: size, startX: startX)

            ZStack(alignment: .topLeading) {
                SoundPathShape(startX: startX)
                    .stroke(EchoColor.ringTrack, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 10]))
                SoundPathShape(startX: startX)
                    .trim(from: 0, to: progress)
                    .stroke(EchoColor.accentFill, style: StrokeStyle(lineWidth: 6, lineCap: .round))

                GoalArt(name: goalImage)
                    .frame(width: size.height * 0.5, height: size.height * 0.5)
                    .position(x: goalPoint.x + size.height * 0.12, y: goalPoint.y - size.height * 0.2)

                ForEach(Array(stops.enumerated()), id: \.offset) { index, stop in
                    let point = SoundPathCurve.point(at: Double(index + 1) / Double(stops.count + 1),
                                                     in: size, startX: startX)
                    PathStopMarker(stop: stop)
                        .position(point)
                    if stop == .tryAgain {
                        TryAgainTag()
                            .onGeometryChange(for: CGFloat.self, of: \.size.width) { tagWidth = $0 }
                            .position(x: tagCenterX(under: point.x,
                                                    clearOf: friendPoint.x + friendSize / 2,
                                                    in: size.width),
                                      y: point.y + 34)
                    }
                }
                .zIndex(1)

                // The friend stays where it is after a try that doesn't count, and is always drawn on
                // top, so nothing on the path covers or tints it.
                EchoAssetImage(name: travelImage)
                    .frame(width: friendSize, height: friendSize)
                    .position(x: friendPoint.x,
                              y: friendPoint.y - friendSize * 0.32)
                    .zIndex(2)
            }
            .animation(reduceMotion ? nil : .spring(duration: 0.7, bounce: 0.25), value: progress)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    /// The friend's picture: the design size, 62% of the path height.
    static func friendSize(in size: CGSize) -> CGFloat { size.height * 0.62 }

    /// Where the path starts across the width.
    static func startX(friendSize: CGFloat, width: CGFloat) -> Double { 0.10 }

    /// Centres the tag under its stop, nudged right just enough to clear the friend's
    /// picture and kept inside the path area.
    private func tagCenterX(under stopX: CGFloat, clearOf friendTrailing: CGFloat, in width: CGFloat) -> CGFloat {
        let half = tagWidth / 2
        let clear = friendTrailing + EchoSpacing.s + half
        return min(max(stopX, clear), width - half)
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
