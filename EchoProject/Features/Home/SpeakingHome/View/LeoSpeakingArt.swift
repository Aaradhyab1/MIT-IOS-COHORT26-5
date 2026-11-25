import SwiftUI

/// Leo speaking on the grass mound, with sound waves pulsing from his mouth.
/// Figma: "Hero art — Leo speaking on grass (animated)".
struct LeoSpeakingArt: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        EchoGrassStage(size: 156, characterScale: 0.96, characterTop: 0.006) {
            EchoAssetImage(name: "img_leo_speaking")
                .blendMode(.multiply)   // the art's white backdrop disappears, as in Figma
        }
        .overlay(alignment: .topLeading) {
            // Three arcs that light up one after another, like the Figma "Sound wave 1–3".
            Image(systemName: "wave.3.right")
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(EchoColor.accent)
                .symbolEffect(.variableColor.iterative.reversing, options: .repeating, isActive: !reduceMotion)
                .offset(x: 106, y: 40)
                .accessibilityHidden(true)
        }
    }
}
