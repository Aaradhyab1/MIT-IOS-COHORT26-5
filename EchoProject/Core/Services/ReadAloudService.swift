import Foundation
import AVFoundation
import Speech

/// Why listening could not start, so the screen can say what to fix.
enum ReadAloudFailure: Equatable {
    /// No microphone: a Mac without one running the Simulator, or the input is in use.
    case noMicrophone
    /// The speech recogniser is not available right now (for example offline, on an
    /// iPhone that cannot recognise speech on the device).
    case recognizerUnavailable
    /// iOS refused the audio setup or the microphone failed to start.
    case audioFailed
}

/// One word the recogniser heard, with the other spellings it also considered for that
/// moment ("wonder" / "wander"). All lowercase, without punctuation. A passage word
/// counts as said when it equals one of these exactly; confidence scores are not used.
struct HeardWord: Equatable {
    let options: [String]

    /// Each word of a plain text, with no alternatives: "How I" → [["how"], ["i"]].
    static func words(in text: String) -> [HeardWord] {
        PronunciationScorer.words(in: text).map { HeardWord(options: [$0]) }
    }

    func matches(_ expected: String) -> Bool {
        !expected.isEmpty && options.contains(expected)
    }
}

/// Listens while the child reads a passage aloud and reports the words heard so far,
/// live, so the screen can highlight each word as it is read.
///
/// Deciding which words of the passage were read is the ViewModel's job (with
/// `ReadingTracker`), not the service's.
/// This release: `LiveReadAloudService` in the app, `DummyReadAloudService` in previews
/// and tests.
@MainActor
protocol ReadAloudService: AnyObject {
    var isListening: Bool { get }
    /// Asks for microphone and speech recognition permission. False if either is refused.
    func requestPermission() async -> Bool
    /// Starts listening. Returns nil once listening, or why it could not start.
    ///
    /// - `expecting`: the passage, used to help the recogniser with its words.
    /// - `onHeard`: every word heard since this call, sent again each time it changes.
    /// - `onStopped`: called if listening ends on its own (an error, a phone call,
    ///   or the recogniser's time limit). Not called after `stop()`.
    func start(
        expecting text: String,
        onHeard: @escaping ([HeardWord]) -> Void,
        onStopped: @escaping () -> Void
    ) -> ReadAloudFailure?
    /// Stops listening. Safe to call when nothing is running.
    func stop()
}

/// Real live speech-to-text with the microphone (AVAudioEngine) and Apple's speech
/// recogniser (SFSpeechRecognizer) with partial results, on the iPhone when it can.
@MainActor
final class LiveReadAloudService: ReadAloudService {
    private(set) var isListening = false

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    /// Created on first use, after the audio session is set up for recording:
    /// reading the microphone's format before that can report no microphone at all.
    private var engine: AVAudioEngine?
    private var hasTap = false
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    /// Goes up with every start and stop, so late results from an old session are ignored.
    private var session = 0
    private var onHeard: (([HeardWord]) -> Void)?
    private var onStopped: (() -> Void)?

    // MARK: - Permission

    func requestPermission() async -> Bool {
        guard await AVAudioApplication.requestRecordPermission() else {
            print("[Echo reading] Microphone permission refused.")
            return false
        }
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return true
        case .denied, .restricted:
            print("[Echo reading] Speech recognition permission refused.")
            return false
        default:
            return await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { @Sendable status in
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }

    // MARK: - Listening

    func start(
        expecting text: String,
        onHeard: @escaping ([HeardWord]) -> Void,
        onStopped: @escaping () -> Void
    ) -> ReadAloudFailure? {
        stop()
        guard let recognizer, recognizer.isAvailable else {
            print("[Echo reading] The speech recogniser is not available.")
            return .recognizerUnavailable
        }
        guard EchoAudioSession.activate() else { return .audioFailed }

        guard AVAudioSession.sharedInstance().isInputAvailable else {
            print("[Echo reading] No microphone: the audio session has no input.")
            return .noMicrophone
        }

        let engine = self.engine ?? AVAudioEngine()
        self.engine = engine
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            print("[Echo reading] No microphone: input format is \(format).")
            return .noMicrophone
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.taskHint = .dictation
        // The passage's words and the passage itself help the recogniser expect them.
        request.contextualStrings = Array(Set(PronunciationScorer.words(in: text))) + [text]
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }

        input.installTap(onBus: 0, bufferSize: 1024, format: format, block: Self.tap(feeding: request))
        hasTap = true
        engine.prepare()
        do {
            try engine.start()
        } catch {
            print("[Echo reading] The microphone did not start: \(error)")
            stop()
            return .audioFailed
        }

        self.session += 1
        let thisSession = self.session
        self.onHeard = onHeard
        self.onStopped = onStopped
        // Results arrive on a background queue; hop back to the main actor.
        let deliver: @Sendable ([[String]]?, Bool) -> Void = { [weak self] segments, ended in
            Task { @MainActor in
                self?.receive(segments, ended: ended, session: thisSession)
            }
        }
        task = recognizer.recognitionTask(with: request, resultHandler: Self.handler(deliver))
        self.request = request
        isListening = true
        print("[Echo reading] Listening at \(Int(format.sampleRate)) Hz (on device: \(request.requiresOnDeviceRecognition)).")
        return nil
    }

    /// `segments`: for each recognised piece of speech, its best text followed by the
    /// alternatives the recogniser also considered.
    private func receive(_ segments: [[String]]?, ended: Bool, session thisSession: Int) {
        guard session == thisSession else { return }
        if let segments {
            let heard = segments.flatMap { Self.heardWords(from: $0) }
            if !heard.isEmpty { onHeard?(heard) }
        }
        if ended {
            let stopped = onStopped
            stop()
            stopped?()
        }
    }

    func stop() {
        session += 1
        onHeard = nil
        onStopped = nil
        if let engine {
            if engine.isRunning { engine.stop() }
            if hasTap { engine.inputNode.removeTap(onBus: 0) }
        }
        hasTap = false
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        isListening = false
    }

    /// One recognised segment as words. A single word keeps its alternatives.
    private static func heardWords(from segment: [String]) -> [HeardWord] {
        guard let best = segment.first else { return [] }
        let bestWords = PronunciationScorer.words(in: best)
        guard bestWords.count == 1 else { return bestWords.map { HeardWord(options: [$0]) } }
        let alternatives = segment.dropFirst()
            .map(PronunciationScorer.words(in:))
            .filter { $0.count == 1 }
            .map { $0[0] }
        var options = bestWords
        for word in alternatives where !options.contains(word) { options.append(word) }
        return [HeardWord(options: options)]
    }

    // MARK: - Background callbacks

    /// Built outside the main actor: the microphone calls it on its own audio thread.
    private nonisolated static func tap(
        feeding request: SFSpeechAudioBufferRecognitionRequest
    ) -> AVAudioNodeTapBlock {
        { buffer, _ in request.append(buffer) }
    }

    /// Built outside the main actor: the recogniser calls it on a background queue.
    private nonisolated static func handler(
        _ deliver: @escaping @Sendable ([[String]]?, Bool) -> Void
    ) -> (SFSpeechRecognitionResult?, (any Error)?) -> Void {
        { result, error in
            let text = result?.bestTranscription.segments.map { [$0.substring] + $0.alternativeSubstrings }
            if let error {
                print("[Echo reading] Recognition ended: \(error.localizedDescription)")
            }
            deliver(text, error != nil || result?.isFinal == true)
        }
    }
}

/// Pretends the child reads the passage perfectly, one word every `wordInterval`.
/// Previews and tests use it, so they never touch the microphone.
@MainActor
final class DummyReadAloudService: ReadAloudService {
    /// Set to false to act out a parent refusing the microphone.
    var allowsMicrophone = true
    private(set) var isListening = false
    private let wordInterval: Duration
    private var reading: Task<Void, Never>?

    init(wordInterval: Duration = .milliseconds(450)) {
        self.wordInterval = wordInterval
    }

    func requestPermission() async -> Bool { allowsMicrophone }

    func start(
        expecting text: String,
        onHeard: @escaping ([HeardWord]) -> Void,
        onStopped: @escaping () -> Void
    ) -> ReadAloudFailure? {
        stop()
        isListening = true
        let words = text.split(separator: " ").map(String.init)
        let interval = wordInterval
        reading = Task {
            var heard: [String] = []
            for word in words {
                try? await Task.sleep(for: interval)
                guard !Task.isCancelled else { return }
                heard.append(word)
                onHeard(HeardWord.words(in: heard.joined(separator: " ")))
            }
        }
        return nil
    }

    func stop() {
        reading?.cancel()
        reading = nil
        isListening = false
    }
}
