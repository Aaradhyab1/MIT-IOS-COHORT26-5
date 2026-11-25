import SwiftUI

/// Numbered steps joined by lines, ending in a ✓: ① — ② — ③ — ④ — ✓.
/// Steps up to `revealedStep` and the lines between them turn blue.
struct LevelStepRow: View {
    let levelCount: Int
    let revealedStep: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(1...max(levelCount, 1), id: \.self) { step in
                StepCircle(text: "\(step)", isReached: step <= revealedStep)
                StepConnector(isFilled: step < revealedStep)
            }
            StepCircle(text: "\u{2713}", isReached: false, isFinal: true)
        }
    }
}
