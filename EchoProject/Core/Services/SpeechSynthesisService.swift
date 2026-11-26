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
    /// Says one part of a word as it sounds, from its IPA spelling ("ʌn" for "un"),
    /// so "s" comes out as "sss" and not the letter name "ess". `text` is what the
    /// voice falls back to if it can't read the IPA.
    func speakSound(_ text: String, ipa: String) async
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
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = slowly ? 0.3 : 0.42     // 0.5 is normal speed; children need it slower
        await say(utterance)
    }

    func speakSound(_ text: String, ipa: String) async {
        // The IPA attribute tells the voice exactly which sounds to make for this text.
        let ipaKey = NSAttributedString.Key(rawValue: AVSpeechSynthesisIPANotationAttribute)
        let sound = NSAttributedString(string: text, attributes: [ipaKey: ipa])
        let utterance = AVSpeechUtterance(attributedString: sound)
        utterance.rate = 0.3
        await say(utterance)
    }

    /// Speaks one utterance with the US English voice and returns when it has finished.
    private func say(_ utterance: AVSpeechUtterance) async {
        stop()
        EchoAudioSession.activate()
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
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

    func speakSound(_ text: String, ipa: String) async {
        try? await Task.sleep(for: .milliseconds(700))
    }

    func stop() {}
}
