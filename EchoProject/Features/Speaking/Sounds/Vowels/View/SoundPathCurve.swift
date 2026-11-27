import CoreGraphics

/// The gentle arc the sound friend travels along, from the start (t = 0) to the goal (t = 1).
/// Points are fractions of the drawing area, so the path scales with the screen.
enum SoundPathCurve {
    static func point(at t: Double, in size: CGSize) -> CGPoint {
        let x = 0.10 + 0.70 * t
        let y = 0.78 - 0.26 * sin(.pi * t * 0.9) + 0.04 * t
        return CGPoint(x: size.width * x, y: size.height * y)
    }
}
