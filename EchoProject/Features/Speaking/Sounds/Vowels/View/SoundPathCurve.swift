import CoreGraphics

/// The gentle arc the sound friend travels along, from the start (t = 0) to the goal (t = 1).
/// Points are fractions of the drawing area, so the path scales with the screen.
enum SoundPathCurve {
    /// Where the goal sits across the width.
    static let endX = 0.80

    /// `startX` is where the path begins across the width (0 ... 1). `SoundPathView` sets it
    /// so the friend's whole picture fits at the start, on screen.
    static func point(at t: Double, in size: CGSize, startX: Double = 0.10) -> CGPoint {
        let x = startX + (endX - startX) * t
        let y = 0.78 - 0.26 * sin(.pi * t * 0.9) + 0.04 * t
        return CGPoint(x: size.width * x, y: size.height * y)
    }
}
