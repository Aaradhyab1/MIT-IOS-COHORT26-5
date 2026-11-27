import SwiftUI

/// Small coral label under a stop that needs another go. Encouraging, never an error.
struct TryAgainTag: View {
    var body: some View {
        Text("Try this one again")
            .echoFont(.caption, .semibold)
            .foregroundStyle(EchoColor.soundsRetry)
            .padding(.horizontal, EchoSpacing.m)
            .padding(.vertical, EchoSpacing.xs)
            .background(EchoColor.soundsRetrySurface, in: Capsule())
            .fixedSize()
    }
}
