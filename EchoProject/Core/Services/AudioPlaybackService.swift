import Foundation

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
