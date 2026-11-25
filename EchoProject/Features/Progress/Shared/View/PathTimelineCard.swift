import SwiftUI

/// "The listening path" / "The speaking path": every level as a vertical timeline.
struct PathTimelineCard: View {
    let steps: [ProgressPathStep]
    let tint: Color

    var body: some View {
        ProgressPlainCard {
            VStack(spacing: 0) {
                ForEach(steps) { step in
                    PathStepRow(step: step, tint: tint, isLast: step.id == steps.last?.id)
                }
            }
        }
    }
}
