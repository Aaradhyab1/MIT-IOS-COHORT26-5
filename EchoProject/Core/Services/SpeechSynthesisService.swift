import Foundation
import AVFoundation

/// Reads a word or sentence out loud and returns when it has finished.
///
/// Used for "Tap play to hear the word", "Hear pronunciation", tapping a word in
/// Sentences, and the shopkeeper's lines in Conversation. There are no recorded clips
/// yet, so the iPhone's built-in voice says the text instead.
@MainActor
protocol SpeechSynthesisService: AnyObject {
    func speak(_ text: String, slowly: Bool) async
    func stop()
}

/// Uses AVSpeechSynthesizer, the voice built into iOS.
@MainActor
final class SystemSpeechSynthesisService: NSObject, SpeechSynthesisService, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    private var waitingCaller: CheckedContinuation<Void, Never>?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, slowly: Bool) async {
        stop()
        EchoAudioSession.activate()

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = slowly ? 0.3 : 0.42     // 0.5 is normal speed; children need it slower
        currentUtterance = utterance

        await withCheckedContinuation { continuation in
            waitingCaller = continuation
            synthesizer.speak(utterance)
        }
    }

    func stop() {
        currentUtterance = nil
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        resumeWaitingCaller()
    }

    private func finished(_ utterance: ObjectIdentifier) {
        // Ignore late callbacks for an utterance that was already stopped.
        guard let currentUtterance, ObjectIdentifier(currentUtterance) == utterance else { return }
        self.currentUtterance = nil
        resumeWaitingCaller()
    }

    private func resumeWaitingCaller() {
        waitingCaller?.resume()
        waitingCaller = nil
    }

    // MARK: - AVSpeechSynthesizerDelegate (called off the main thread)

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in self.finished(id) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in self.finished(id) }
    }
}

/// Silent stand-in for previews and tests: waits a moment, says nothing.
@MainActor
final class DummySpeechSynthesisService: SpeechSynthesisService {
    func speak(_ text: String, slowly: Bool) async {
        try? await Task.sleep(for: .milliseconds(slowly ? 900 : 600))
    }

    func stop() {}
}
