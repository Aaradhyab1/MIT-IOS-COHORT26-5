import SwiftUI

/// One step: a 28 pt circle with its number, light blue once reached.
struct StepCircle: View {
    let text: String
    let isReached: Bool
    var isFinal = false

    var body: some View {
        Text(text)
            .echoFont(.supporting, .semibold)
            .foregroundStyle(isFinal ? EchoColor.stepDoneText : isReached ? EchoColor.stepReachedText : EchoColor.stepPendingText)
            .frame(width: 28, height: 28)
            .background(isFinal ? EchoColor.stepDone : isReached ? EchoColor.stepReached : EchoColor.stepPending, in: Circle())
    }
}
