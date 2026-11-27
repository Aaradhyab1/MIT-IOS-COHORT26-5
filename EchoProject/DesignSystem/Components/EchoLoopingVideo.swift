import SwiftUI
import AVFoundation
import UIKit

/// Plays a short, muted video on repeat, such as Echo waving his trunk on Listening home.
///
/// Put `<videoName>.mp4` anywhere inside `EchoProject/Resources/` and Xcode copies it
/// into the app. `fallbackImage` is drawn underneath: it fills the moment before the
/// first frame appears, and it is all you see if the video file is missing.
///
///     EchoLoopingVideo(videoName: "echo_home_loop", fallbackImage: "img_echo_home_still")
struct EchoLoopingVideo: View {
    let videoName: String
    let fallbackImage: String

    var body: some View {
        ZStack {
            EchoAssetImage(name: fallbackImage)
            if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                LoopingPlayerView(url: url)
            }
        }
        .allowsHitTesting(false)   // taps pass through to whatever is behind
        .accessibilityHidden(true)
    }
}

/// A transparent video surface (no black background or playback controls) that loops one clip.
/// SwiftUI's `VideoPlayer` always draws black before the first frame, which flashes on
/// light screens, so this wraps a plain `AVPlayerLayer` instead.
private struct LoopingPlayerView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PlayerLayerView {
        let view = PlayerLayerView()
        view.play(url)
        return view
    }

    func updateUIView(_ uiView: PlayerLayerView, context: Context) {}

    static func dismantleUIView(_ uiView: PlayerLayerView, coordinator: ()) {
        uiView.stop()
    }
}

/// A UIView whose layer is an AVPlayerLayer, looping one muted clip.
private final class PlayerLayerView: UIView {
    private let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?

    override class var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    func play(_ url: URL) {
        backgroundColor = .clear
        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.videoGravity = .resizeAspect
        playerLayer.player = player
        player.isMuted = true
        player.preventsDisplaySleepDuringVideoPlayback = false
        looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        player.play()
    }

    func stop() {
        player.pause()
        looper = nil
    }
}
