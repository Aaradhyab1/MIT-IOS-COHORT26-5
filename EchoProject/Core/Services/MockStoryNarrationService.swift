import Foundation

/// Stands in for `SpeechStoryNarrationService` in previews and tests. With
/// `simulatesPlayback` it moves the progress along over a few seconds without sound;
/// without it, tests drive it with `send(_:)`.
@MainActor
final class MockStoryNarrationService: StoryNarrationService {
    enum Call: Equatable {
        case speak(from: Double, speed: NarrationSpeed)
        case pause
        case resume
        case stop
    }

    var onEvent: ((NarrationEvent) -> Void)?
    private(set) var calls: [Call] = []
    private(set) var spokenText: String?

    private let simulatesPlayback: Bool
    private var playback: Task<Void, Never>?
    private var fraction = 0.0

    init(simulatesPlayback: Bool = true) {
        self.simulatesPlayback = simulatesPlayback
    }

    func speak(_ text: String, from fraction: Double, speed: NarrationSpeed) {
        calls.append(.speak(from: fraction, speed: speed))
        spokenText = text
        playback?.cancel()
        self.fraction = fraction
        if simulatesPlayback {
            onEvent?(.started)
            run()
        }
    }

    func pause() {
        calls.append(.pause)
        playback?.cancel()
        if simulatesPlayback {
            onEvent?(.paused)
        }
    }

    func resume() {
        calls.append(.resume)
        if simulatesPlayback {
            onEvent?(.resumed)
            run()
        }
    }

    func stop() {
        calls.append(.stop)
        playback?.cancel()
    }

    func send(_ event: NarrationEvent) {
        onEvent?(event)
    }

    private func run() {
        playback = Task {
            while fraction < 1 {
                do {
                    try await Task.sleep(for: .milliseconds(100))
                } catch {
                    return
                }
                fraction = min(fraction + 0.02, 1)
                onEvent?(.progress(fraction))
            }
            onEvent?(.finished)
        }
    }
}
