import SwiftUI

/// Echo on his grass mound for Today's practice, with the same slow "breathing" as the splash.
/// Plays `echo_hero_loop.mp4` instead of the still if that file is ever added.
struct EchoHeroArt: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isBreathing = false

    var body: some View {
        EchoGrassStage(size: 156) {
            EchoLoopingVideo(videoName: "echo_hero_loop", fallbackImage: "img_echo_hero")
                .echoFeatheredCircle()
                .blendMode(.multiply)
                .scaleEffect(isBreathing ? 1.02 : 1, anchor: .bottom)
                .offset(y: isBreathing ? -2 : 0)
        }
        .onAppear(perform: startBreathing)
    }

    private func startBreathing() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
            isBreathing = true
        }
    }
}
