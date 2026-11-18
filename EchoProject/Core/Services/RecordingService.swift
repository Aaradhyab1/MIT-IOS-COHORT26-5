import Foundation

/// Which recording path the dummy service acts out, so every prototype
/// screen (including mic denied and no voice) can be shown in the demo.
enum RecordingScenario: String, CaseIterable, Identifiable {
    case normal
    case micDenied
    case noVoice

    var id: String { rawValue }
}

/// Raw facts about a recording. Deciding what they mean (e.g. "no voice")
/// is the ViewModel's job, not the service's.
struct RecordingResult: Hashable {
    let fileName: String?       // nil for dummy recordings
    let duration: TimeInterval
    let peakLevel: Double       // 0.0 (silence) ... 1.0 (loud)
}

@MainActor
protocol RecordingService: AnyObject {
    var isRecording: Bool { get }
    func requestPermission() async -> Bool
    func startRecording()
    func stopRecording() -> RecordingResult
    func playRecording(_ result: RecordingResult) async
}

@MainActor
final class DummyRecordingService: RecordingService {
    /// Set from a hidden debug menu so a demo can show every recording state.
    var scenario: RecordingScenario = .normal

    private(set) var isRecording = false
    private var startedAt: Date?

    func requestPermission() async -> Bool {
        scenario != .micDenied
    }

    func startRecording() {
        isRecording = true
        startedAt = Date()
    }

    func stopRecording() -> RecordingResult {
        let duration = startedAt.map { Date().timeIntervalSince($0) } ?? 0
        isRecording = false
        startedAt = nil
        return RecordingResult(
            fileName: nil,
            duration: duration,
            peakLevel: scenario == .noVoice ? 0.02 : 0.6
        )
    }

    func playRecording(_ result: RecordingResult) async {
        let seconds = min(max(result.duration, 1), 3)
        try? await Task.sleep(for: .seconds(seconds))
    }
}
