import SwiftUI

/// The white capsule under the friend that shows the sound: "aaa".
struct VowelPill: View {
    let vowel: String

    var body: some View {
        Text(vowel)
            .echoFont(.title, .bold)
            .foregroundStyle(EchoColor.textPrimary)
            .padding(.horizontal, EchoSpacing.xxl)
            .padding(.vertical, EchoSpacing.xs)
            .background(EchoColor.pillSurface, in: Capsule())
            .echoShadow(.badge)
            .accessibilityLabel("Sound: \(vowel)")
    }
}

#Preview {
    VowelPill(vowel: "aaa")
        .padding()
        .echoScreenBackground()
}
