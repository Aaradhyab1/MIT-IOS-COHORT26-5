import SwiftUI

/// One row on "How it works": picture and a short step.
struct VowelIntroRow: View {
    let step: IntroStep

    var body: some View {
        HStack(spacing: EchoSpacing.l) {
            icon
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

    @ViewBuilder
    private var icon: some View {
        switch step.icon {
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(EchoColor.accent)
                .frame(width: 52, height: 52)
                .background(EchoColor.Paper.sky, in: Circle())
                .accessibilityHidden(true)
        case .image(let name):
            EchoAssetImage(name: name)
        }
    }
}
