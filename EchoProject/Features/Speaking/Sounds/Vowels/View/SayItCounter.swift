import SwiftUI

/// "★★☆ 2 of 3": good tries so far for the current friend.
struct SayItCounter: View {
    let count: Int
    let total: Int

    var body: some View {
        HStack(spacing: EchoSpacing.xs) {
            ForEach(0..<total, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(index < count ? EchoColor.soundsStar : EchoColor.ringTrack)
            }
            Text("\(count) of \(total)")
                .echoFont(.supporting, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .padding(.leading, EchoSpacing.xs)
        }
        .padding(.horizontal, EchoSpacing.m)
        .padding(.vertical, EchoSpacing.s)
        .background(EchoColor.pillSurface, in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(count) of \(total) stars")
    }
}

#Preview {
    SayItCounter(count: 2, total: 3)
        .padding()
        .echoScreenBackground()
}
