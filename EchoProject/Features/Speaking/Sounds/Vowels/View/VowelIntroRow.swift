import SwiftUI

/// One row on "How it works": picture and a short step.
struct VowelIntroRow: View {
    let step: IntroStep

    var body: some View {
        HStack(spacing: EchoSpacing.l) {
            EchoAssetImage(name: step.icon)
                .frame(width: 52, height: 52)
            Text(step.title)
                .echoFont(.body, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, EchoSpacing.l)
        .padding(.vertical, EchoSpacing.m)
        .background(EchoColor.cardSurface, in: .rect(cornerRadius: EchoRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: EchoRadius.card)
                .strokeBorder(EchoColor.surfaceStroke, lineWidth: 1.5)
        }
        .accessibilityElement(children: .combine)
    }
}
