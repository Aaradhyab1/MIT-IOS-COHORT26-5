import SwiftUI

/// The path line. Draw it dashed for the way still to go, and trimmed and solid for the trail.
struct SoundPathShape: Shape {
    var startX: Double = 0.10

    func path(in rect: CGRect) -> Path {
        Path { path in
            let steps = 40
            for step in 0...steps {
                let point = SoundPathCurve.point(at: Double(step) / Double(steps), in: rect.size, startX: startX)
                if step == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
        }
    }
}
