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

/// Why listening ended by itself.
enum ReadAloudStop: Equatable {
    /// The recogniser finished: a long pause, its time limit, or it heard nothing.
    case recognizerEnded
    /// Another app or a phone call took over the audio.
    case interrupted
    /// Recognition failed with an error.
    case failed
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

/// How long the child has been quiet after speaking.
enum ReadAloudQuiet: Equatable {
    /// About half a second: a breath between words, or the end of the reading.
    case pause
    /// A few seconds: the child has stopped reading.
    case long
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
    /// - `onQuiet`: the child spoke and has now been quiet for a short pause, then
    ///   (if still quiet) for a long silence. Sent again after each stretch of speech.
    /// - `onStopped`: called with the reason if listening ends on its own (an error,
    ///   a phone call, the recogniser's time limit, or after `finish()`).
    ///   Not called after `stop()`.
    func start(
        expecting text: String,
        onHeard: @escaping ([HeardWord]) -> Void,
        onQuiet: @escaping (ReadAloudQuiet) -> Void,
        onStopped: @escaping (ReadAloudStop) -> Void
    ) -> ReadAloudFailure?
    /// The child has finished: stop taking audio and get the recogniser's final words
    /// right away, instead of waiting for it to notice the silence. The final words
    /// arrive through `onHeard`, then `onStopped(.recognizerEnded)`.
    func finish()
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
    private var onQuiet: ((ReadAloudQuiet) -> Void)?
    private var onStopped: ((ReadAloudStop) -> Void)?
    private var interruptionObserver: (any NSObjectProtocol)?
    private var audioObservers: [any NSObjectProtocol] = []

    // Telling speech from silence, from the microphone level.
    /// Quiet this long after speaking is a pause (`onQuiet(.pause)`).
    private static let pauseLength: Duration = .milliseconds(600)
    /// Quiet this long after speaking is a long silence (`onQuiet(.long)`).
    private static let silenceLength: Duration = .seconds(3)
    /// After `finish()`, the longest wait for the recogniser's final words.
    private static let finalResultWait: Duration = .milliseconds(1500)
    private var hasReportedPause = false
    /// Loudness of the room with nobody speaking, in decibels; follows the quietest level.
    private var noiseFloor: Float = -60
    private var lastSpeech: ContinuousClock.Instant?
    private var isSpeaking = false

    init() {
        // A phone call, Siri or another app taking the audio stops listening cleanly.
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification, object: nil, queue: .main
        ) { [weak self] note in
            let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
            guard raw == AVAudioSession.InterruptionType.began.rawValue else { return }
            MainActor.assumeIsolated { self?.endListening(.interrupted) }
        }
    }

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
        onQuiet: @escaping (ReadAloudQuiet) -> Void,
        onStopped: @escaping (ReadAloudStop) -> Void
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
        if self.engine == nil { observeAudioChanges(of: engine) }
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

        self.session += 1
        let thisSession = self.session
        let level: @Sendable (Float) -> Void = { [weak self] decibels in
            let service = self
            Task { @MainActor in service?.receiveLevel(decibels, session: thisSession) }
        }
        input.installTap(onBus: 0, bufferSize: 1024, format: format, block: Self.tap(feeding: request, level: level))
        hasTap = true
        engine.prepare()
        do {
            try engine.start()
        } catch {
            print("[Echo reading] The microphone did not start: \(error)")
            stop()
            return .audioFailed
        }

        self.onHeard = onHeard
        self.onQuiet = onQuiet
        self.onStopped = onStopped
        noiseFloor = -60
        lastSpeech = nil
        isSpeaking = false
        hasReportedPause = false
        // Results arrive on a background queue; hop back to the main actor.
        let deliver: @Sendable ([[String]]?, ReadAloudStop?) -> Void = { [weak self] segments, ended in
            let service = self
            Task { @MainActor in
                service?.receive(segments, ended: ended, session: thisSession)
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
    private func receive(_ segments: [[String]]?, ended: ReadAloudStop?, session thisSession: Int) {
        guard session == thisSession else { return }
        if let segments {
            let heard = segments.flatMap { Self.heardWords(from: $0) }
            if !heard.isEmpty { onHeard?(heard) }
        }
        if let ended { endListening(ended) }
    }

    /// Speech is anything clearly louder than the room. Once the child has spoken and then
    /// stays quiet, `onQuiet(.pause)` and later `onQuiet(.long)` are sent, once each per
    /// stretch of speech.
    private func receiveLevel(_ decibels: Float, session thisSession: Int) {
        guard session == thisSession, isListening else { return }
        if decibels < noiseFloor {
            noiseFloor = decibels
        } else {
            noiseFloor += (decibels - noiseFloor) * 0.002   // drifts up slowly in a noisier room
        }
        let now = ContinuousClock.now
        if decibels > max(noiseFloor + 12, -55) {
            lastSpeech = now
            isSpeaking = true
            hasReportedPause = false
        } else if isSpeaking, let lastSpeech {
            let quiet = now - lastSpeech
            if quiet >= Self.silenceLength {
                isSpeaking = false
                onQuiet?(.long)
            } else if quiet >= Self.pauseLength, !hasReportedPause {
                hasReportedPause = true
                onQuiet?(.pause)
            }
        }
    }

    func finish() {
        guard isListening else { return }
        // Stop the microphone but keep the recognition task: ending the audio makes the
        // recogniser deliver its final result straight away.
        if let engine {
            if engine.isRunning { engine.stop() }
            if hasTap { engine.inputNode.removeTap(onBus: 0) }
        }
        hasTap = false
        onQuiet = nil
        request?.endAudio()
        // Normally the final result arrives within a moment. If it never does, end anyway
        // with what was heard, so the child is never left waiting.
        let thisSession = session
        Task { [weak self] in
            try? await Task.sleep(for: Self.finalResultWait)
            guard let self, self.session == thisSession else { return }
            print("[Echo reading] No final result after finishing; ending with what was heard.")
            self.endListening(.recognizerEnded)
        }
    }

    /// Headphones plugged in or out, a Bluetooth microphone dropping, or the audio
    /// system restarting all stop the microphone; treat them like an interruption so
    /// the child can carry on from the current word.
    private func observeAudioChanges(of engine: AVAudioEngine) {
        let center = NotificationCenter.default
        audioObservers.append(center.addObserver(
            forName: .AVAudioEngineConfigurationChange, object: engine, queue: .main
        ) { [weak self] _ in
            // Delivered on the main queue.
            MainActor.assumeIsolated {
                guard let self, self.engine?.isRunning == false else { return }
                print("[Echo reading] The audio route changed; listening stopped.")
                self.endListening(.interrupted)
            }
        })
        audioObservers.append(center.addObserver(
            forName: AVAudioSession.mediaServicesWereResetNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                print("[Echo reading] The audio system restarted; listening stopped.")
                self?.endListening(.interrupted)
            }
        })
    }

    /// Stops and tells the ViewModel why. Does nothing when not listening.
    private func endListening(_ reason: ReadAloudStop) {
        guard isListening else { return }
        let stopped = onStopped
        stop()
        stopped?(reason)
    }

    func stop() {
        session += 1
        onHeard = nil
        onQuiet = nil
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
        feeding request: SFSpeechAudioBufferRecognitionRequest,
        level: @escaping @Sendable (Float) -> Void
    ) -> AVAudioNodeTapBlock {
        { buffer, _ in
            request.append(buffer)
            level(decibels(of: buffer))
        }
    }

    /// Average loudness of one buffer of microphone audio, in decibels (−100 … 0).
    private nonisolated static func decibels(of buffer: AVAudioPCMBuffer) -> Float {
        guard let samples = buffer.floatChannelData?[0], buffer.frameLength > 0 else { return -100 }
        let count = Int(buffer.frameLength)
        var sum: Float = 0
        for index in 0..<count { sum += samples[index] * samples[index] }
        let rms = (sum / Float(count)).squareRoot()
        return max(20 * log10(max(rms, 1e-7)), -100)
    }

    /// Built outside the main actor: the recogniser calls it on a background queue.
    private nonisolated static func handler(
        _ deliver: @escaping @Sendable ([[String]]?, ReadAloudStop?) -> Void
    ) -> (SFSpeechRecognitionResult?, (any Error)?) -> Void {
        { result, error in
            let text = result?.bestTranscription.segments.map { [$0.substring] + $0.alternativeSubstrings }
            if let error {
                print("[Echo reading] Recognition ended: \(error.localizedDescription)")
            }
            let ended: ReadAloudStop?
            if let error = error as NSError? {
                // 1110: "No speech detected" — the recogniser simply heard nothing.
                ended = error.code == 1110 ? .recognizerEnded : .failed
            } else {
                ended = result?.isFinal == true ? .recognizerEnded : nil
            }
            deliver(text, ended)
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
    private var onStopped: ((ReadAloudStop) -> Void)?

    init(wordInterval: Duration = .milliseconds(450)) {
        self.wordInterval = wordInterval
    }

    func requestPermission() async -> Bool { allowsMicrophone }

    func start(
        expecting text: String,
        onHeard: @escaping ([HeardWord]) -> Void,
        onQuiet: @escaping (ReadAloudQuiet) -> Void,
        onStopped: @escaping (ReadAloudStop) -> Void
    ) -> ReadAloudFailure? {
        stop()
        isListening = true
        self.onStopped = onStopped
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

    func finish() {
        let stopped = onStopped
        stop()
        stopped?(.recognizerEnded)
    }

    func stop() {
        reading?.cancel()
        reading = nil
        onStopped = nil
        isListening = false
    }
}
