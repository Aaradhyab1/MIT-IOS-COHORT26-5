import SwiftUI

/// One dot per question; the current question is a wider blue capsule.
struct QuestionProgressDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: EchoSpacing.s) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? EchoColor.accent : EchoColor.progressDot)
                    .frame(width: index == current ? 18 : 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Question \(current + 1) of \(count)")
    }
}
