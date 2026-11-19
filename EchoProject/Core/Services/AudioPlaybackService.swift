import Foundation
import AVFoundation

/// Plays a clip and returns when it ends.
/// This release: `DummyAudioPlaybackService` waits ~2 s and plays no sound,
/// so templates can show their "playing" state.
@MainActor
protocol AudioPlaybackService: AnyObject {
    var isPlaying: Bool { get }
    func play(_ clip: String) async
    func stop()
}

@MainActor
final class DummyAudioPlaybackService: AudioPlaybackService {
    private(set) var isPlaying = false
    private let simulatedDuration: Duration
    private var playback: Task<Void, Never>?

    init(simulatedDuration: Duration = .seconds(2)) {
        self.simulatedDuration = simulatedDuration
    }

    func play(_ clip: String) async {
        stop()
        isPlaying = true
        let duration = simulatedDuration
        let task = Task {
            _ = try? await Task.sleep(for: duration)
        }
        playback = task
        await task.value
        isPlaying = false
    }

    func stop() {
        playback?.cancel()
        playback = nil
        isPlaying = false
    }
}

/// Plays bundled sound effects when available and keeps the dummy timing behavior
/// for exercises whose sound files have not been added yet.
@MainActor
final class BundleAudioPlaybackService: NSObject, AudioPlaybackService, AVAudioPlayerDelegate {
    private let fallback = DummyAudioPlaybackService()
    private var player: AVAudioPlayer?
    private var playbackContinuation: CheckedContinuation<Void, Never>?

    var isPlaying: Bool { player?.isPlaying ?? fallback.isPlaying }

    func play(_ clip: String) async {
        stop()

        let resourceName = clip.hasPrefix("snd_") ? String(clip.dropFirst(4)) : clip
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "mp3") else {
            await fallback.play(clip)
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            self.player = player
            player.delegate = self

            await withCheckedContinuation { continuation in
                playbackContinuation = continuation
                guard EchoAudioSession.activate(), player.play() else {
                    finishPlayback(for: player)
                    return
                }
            }
        } catch {
            await fallback.play(clip)
        }
    }

    func stop() {
        fallback.stop()
        guard let player else { return }

        self.player = nil
        player.delegate = nil
        player.stop()
        playbackContinuation?.resume()
        playbackContinuation = nil
    }

    private func finishPlayback(for player: AVAudioPlayer) {
        guard let currentPlayer = self.player,
              ObjectIdentifier(currentPlayer) == ObjectIdentifier(player) else { return }

        self.player = nil
        player.delegate = nil
        playbackContinuation?.resume()
        playbackContinuation = nil
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let playerId = ObjectIdentifier(player)
        Task { @MainActor in
            guard let currentPlayer = self.player,
                  ObjectIdentifier(currentPlayer) == playerId else { return }
            self.finishPlayback(for: currentPlayer)
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        let playerId = ObjectIdentifier(player)
        Task { @MainActor in
            guard let currentPlayer = self.player,
                  ObjectIdentifier(currentPlayer) == playerId else { return }
            self.finishPlayback(for: currentPlayer)
        }
    }
}
