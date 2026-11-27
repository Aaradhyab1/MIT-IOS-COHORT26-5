import SwiftUI

/// The big mic button. While Echo is listening it glows with soft rings.
struct VowelMicButton: View {
    let isActive: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            Image(systemName: "mic.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(EchoColor.textOnAccent)
                .frame(width: 84, height: 84)
                .background(EchoColor.accentFill, in: Circle())
                .echoShadow(.primaryButton)
        }
        .buttonStyle(.plain)
        .background {
            if isActive {
                Circle()
                    .fill(EchoColor.accentFill.opacity(0.14))
                    .frame(width: 150, height: 150)
                    .phaseAnimator([1.0, 1.08]) { ring, scale in
                        ring.scaleEffect(reduceMotion ? 1 : scale)
                    } animation: { _ in .easeInOut(duration: 0.8) }
                Circle()
                    .fill(EchoColor.accentFill.opacity(0.20))
                    .frame(width: 118, height: 118)
            }
        }
        .accessibilityLabel(isActive ? "Stop" : "Start talking")
    }
}

#Preview {
    HStack(spacing: 60) {
        VowelMicButton(isActive: false) {}
        VowelMicButton(isActive: true) {}
    }
    .padding(60)
    .echoScreenBackground()
}
