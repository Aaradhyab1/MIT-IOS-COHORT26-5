import SwiftUI
import AVKit

/// Plays a short, muted video on repeat, such as Echo waving his trunk on the splash.
///
/// Put `<videoName>.mp4` anywhere inside `EchoProject/Resources/` and Xcode copies it
/// into the app. Until the file exists, `fallbackImage` is shown instead (or its dashed
/// placeholder), so the screen works before the video is exported.
///
///     EchoLoopingVideo(videoName: "echo_hero_loop", fallbackImage: "img_echo_hero")
struct EchoLoopingVideo: View {
    let videoName: String
    let fallbackImage: String

    @State private var looper = VideoLooper()

    var body: some View {
        if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
            VideoPlayer(player: looper.player)
                .allowsHitTesting(false)   // no playback controls; taps pass through
                .onAppear { looper.play(url) }
                .onDisappear { looper.pause() }
                .accessibilityHidden(true)
        } else {
            EchoAssetImage(name: fallbackImage)
        }
    }
}

/// Keeps one muted player looping the same clip. Lives in @State so the
/// player survives while SwiftUI redraws the view.
private final class VideoLooper {
    let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?

    func play(_ url: URL) {
        if looper == nil {
            player.isMuted = true
            looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        }
        player.play()
    }

    func pause() {
        player.pause()
    }
}
