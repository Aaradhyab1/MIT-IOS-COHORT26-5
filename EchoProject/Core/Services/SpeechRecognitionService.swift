import Foundation
import AVFoundation
import Speech

/// Turns a recording of the child into text.
///
/// Deciding whether that text is right is the ViewModel's job (with `PronunciationScorer`),
/// not the service's.
/// This release: `LiveSpeechRecognitionService` in the app, `DummySpeechRecognitionService`
/// in previews and tests.
@MainActor
protocol SpeechRecognitionService: AnyObject {
    /// Asks for speech recognition permission. Returns false if the parent said no.
    func requestPermission() async -> Bool
    /// Makes sure the on-device English speech model is installed, downloading it the
    /// first time. Returns false if this iPhone cannot transcribe English.
    func prepare() async -> Bool
    /// What the child said, as plain text. Empty when nothing was understood.
    /// `expecting` lists the word or sentence the child is trying to say.
    func transcribe(_ recording: RecordingResult, expecting: [String]) async -> String
    /// Live captions while the child is still talking: `onHeard` gets everything heard so
    /// far, again and again. Lets a screen stop recording as soon as the answer is said.
    /// Runs next to the recording; call `stopListening()` when the recording stops.
    func startListening(expecting: [String], onHeard: @escaping @MainActor (String) -> Void)
    func stopListening()
}

/// Real speech-to-text with Apple's SpeechAnalyzer (iOS 26), running fully on the iPhone.
///
/// Steps for each recording (the same order Apple's sample and Firefox for iOS use):
/// 1. Ask the analyzer which audio format it wants, and warm the model up.
/// 2. Read the recording and convert it to that format (a mismatch gives no text at all).
/// 3. Start listening for results *before* feeding in the audio.
/// 4. Feed the audio, mark the end of input, and wait for the final text.
///
/// Uses `SpeechTranscriber` first. If it hears nothing, it tries `DictationTranscriber`,
/// which is tuned for short phrases.
@MainActor
final class LiveSpeechRecognitionService: SpeechRecognitionService {
    private var transcriberLocale: Locale?
    private var dictationLocale: Locale?

    enum RecognitionError: Error {
        case couldNotReadRecording
        case couldNotConvertAudio
    }

    /// Used when the analyzer can't suggest a format (seen in the Simulator):
    /// 16 kHz mono 16-bit, the usual format for speech models.
    private static let fallbackFormat = AVAudioFormat(
        commonFormat: .pcmFormatInt16, sampleRate: 16_000, channels: 1, interleaved: true
    )

    // MARK: - Permission

    func requestPermission() async -> Bool {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return true
        case .denied, .restricted:
            return false
        default:
            return await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { @Sendable status in
                    continuation.resume(returning: status == .authorized)
                }
            }
        }
    }

    // MARK: - Model download

    /// Apple's older recogniser, from the same Speech framework. Last fallback: it works in
    /// the Simulator, where SpeechAnalyzer's models are missing.
    private let legacyRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var isPrepared = false

    func prepare() async -> Bool {
        if isPrepared { return true }
        defer { isPrepared = true }
        let english = Locale(identifier: "en-US")

        if let locale = await SpeechTranscriber.supportedLocale(equivalentTo: english) {
            let module = SpeechTranscriber(locale: locale, transcriptionOptions: [], reportingOptions: [], attributeOptions: [])
            if await install(module, name: "SpeechTranscriber") { transcriberLocale = locale }
        } else {
            print("[Echo speech] SpeechTranscriber does not support English on this device.")
        }

        if let locale = await DictationTranscriber.supportedLocale(equivalentTo: english) {
            let module = DictationTranscriber(locale: locale, preset: .shortDictation)
            if await install(module, name: "DictationTranscriber") { dictationLocale = locale }
        } else {
            print("[Echo speech] DictationTranscriber does not support English on this device.")
        }

        let legacyAvailable = legacyRecognizer?.isAvailable == true
        let ready = transcriberLocale != nil || dictationLocale != nil || legacyAvailable
        print("[Echo speech] Ready: \(ready) (SpeechTranscriber: \(transcriberLocale != nil), DictationTranscriber: \(dictationLocale != nil), SFSpeechRecognizer: \(legacyAvailable))")
        return ready
    }

    private func install(_ module: any SpeechModule, name: String) async -> Bool {
        do {
            if let download = try await AssetInventory.assetInstallationRequest(supporting: [module]) {
                print("[Echo speech] Downloading the \(name) model…")
                try await download.downloadAndInstall()
            }
            return true
        } catch {
            print("[Echo speech] Could not install the \(name) model: \(error)")
            return false
        }
    }

    // MARK: - Transcribing

    func transcribe(_ recording: RecordingResult, expecting: [String]) async -> String {
        guard let fileName = recording.fileName else {
            print("[Echo speech] No recording file to transcribe.")
            return ""
        }
        guard await prepare() else { return "" }
        let url = RecordingFiles.url(for: fileName)

        if let locale = transcriberLocale {
            let transcriber = SpeechTranscriber(locale: locale, transcriptionOptions: [], reportingOptions: [], attributeOptions: [])
            let text = await run(url, module: transcriber, name: "SpeechTranscriber") {
                var final = ""
                var latest = ""
                for try await result in transcriber.results {
                    let piece = String(result.text.characters)
                    if result.isFinal { final += piece + " " } else { latest = piece }
                }
                return final.isEmpty ? latest : final
            }
            if !text.isEmpty {
                print("[Echo speech] Heard: \"\(text)\" (expected \(expecting))")
                return text
            }
        }

        if let locale = dictationLocale {
            let dictation = DictationTranscriber(locale: locale, preset: .shortDictation)
            let text = await run(url, module: dictation, name: "DictationTranscriber") {
                var final = ""
                var latest = ""
                for try await result in dictation.results {
                    let piece = String(result.text.characters)
                    if result.isFinal { final += piece + " " } else { latest = piece }
                }
                return final.isEmpty ? latest : final
            }
            print("[Echo speech] Heard: \"\(text)\" (expected \(expecting))")
            return text
        }

        print("[Echo speech] Heard nothing (expected \(expecting))")
        return ""
    }

    /// Runs one analysis of the recording with one module and returns its text.
    private func run(
        _ url: URL,
        module: any SpeechModule,
        name: String,
        collectResults: @escaping () async throws -> String
    ) async -> String {
        do {
            // 1. The format the model wants, and warm it up.
            // The Simulator often has no suggestion, so fall back to 16 kHz mono.
            guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [module])
                    ?? Self.fallbackFormat else {
                throw RecognitionError.couldNotConvertAudio
            }
            let analyzer = SpeechAnalyzer(modules: [module])
            try await analyzer.prepareToAnalyze(in: format)

            // 2. The recording, converted to that format.
            let audio = try Self.readAudio(from: url, convertedTo: format)
            print("[Echo speech] \(name): \(audio.frameLength) frames at \(Int(format.sampleRate)) Hz")

            // 3. Listen for results before any audio goes in.
            let collector = Task { try await collectResults() }
            await Task.yield()

            // 4. Feed the audio, end the input, wait for the final text.
            let (input, continuation) = AsyncStream.makeStream(of: AnalyzerInput.self)
            try await analyzer.start(inputSequence: input)
            continuation.yield(AnalyzerInput(buffer: audio))
            continuation.finish()
            try await analyzer.finalizeAndFinishThroughEndOfInput()

            return try await collector.value.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("[Echo speech] \(name) failed: \(error)")
            return ""
        }
    }

    /// Reads the whole recording and converts it to the analyzer's format
    /// (sample rate, sample type and channel count).
    private static func readAudio(from url: URL, convertedTo format: AVAudioFormat) throws -> AVAudioPCMBuffer {
        let file = try AVAudioFile(forReading: url)
        let sourceFormat = file.processingFormat
        guard let source = AVAudioPCMBuffer(pcmFormat: sourceFormat, frameCapacity: AVAudioFrameCount(file.length)) else {
            throw RecognitionError.couldNotReadRecording
        }
        try file.read(into: source)

        if sourceFormat == format { return source }

        guard let converter = AVAudioConverter(from: sourceFormat, to: format) else {
            throw RecognitionError.couldNotConvertAudio
        }
        let ratio = format.sampleRate / sourceFormat.sampleRate
        let capacity = AVAudioFrameCount(Double(source.frameLength) * ratio) + 1_024
        guard let converted = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else {
            throw RecognitionError.couldNotConvertAudio
        }

        var handedOver = false
        var conversionError: NSError?
        let status = converter.convert(to: converted, error: &conversionError) { _, inputStatus in
            if handedOver {
                inputStatus.pointee = .endOfStream
                return nil
            }
            handedOver = true
            inputStatus.pointee = .haveData
            return source
        }
        if status == .error {
            if let conversionError { throw conversionError }
            throw RecognitionError.couldNotConvertAudio
        }
        return converted
    }

    // MARK: - Live captions

    private let liveEngine = AVAudioEngine()
    private var liveRequest: SFSpeechAudioBufferRecognitionRequest?
    private var liveTask: SFSpeechRecognitionTask?

    /// Streams the microphone into Apple's SFSpeechRecognizer with partial results on.
    func startListening(expecting: [String], onHeard: @escaping @MainActor (String) -> Void) {
        stopListening()
        guard let recognizer = legacyRecognizer, recognizer.isAvailable else {
            print("[Echo speech] Live captions are not available.")
            return
        }
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.contextualStrings = expecting
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }

        let input = liveEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else {
            print("[Echo speech] Live captions: no microphone input format.")
            return
        }
        input.installTap(onBus: 0, bufferSize: 1_024, format: format) { @Sendable buffer, _ in
            request.append(buffer)
        }
        liveEngine.prepare()
        do {
            try liveEngine.start()
        } catch {
            print("[Echo speech] Live captions could not start: \(error)")
            input.removeTap(onBus: 0)
            return
        }

        liveRequest = request
        liveTask = recognizer.recognitionTask(with: request) { @Sendable result, _ in
            guard let text = result?.bestTranscription.formattedString, !text.isEmpty else { return }
            Task { @MainActor in onHeard(text) }
        }
    }

    func stopListening() {
        if liveEngine.isRunning {
            liveEngine.stop()
            liveEngine.inputNode.removeTap(onBus: 0)
        }
        liveRequest?.endAudio()
        liveTask?.cancel()
        liveRequest = nil
        liveTask = nil
    }
}

/// Pretends to understand the child perfectly, after a short pause.
/// Set `heardText` in a preview or test to act out a wrong or empty answer.
@MainActor
final class DummySpeechRecognitionService: SpeechRecognitionService {
    var heardText: String?
    var isAvailable = true

    func requestPermission() async -> Bool { true }

    func prepare() async -> Bool { isAvailable }

    func transcribe(_ recording: RecordingResult, expecting: [String]) async -> String {
        try? await Task.sleep(for: .milliseconds(600))
        return heardText ?? expecting.first ?? ""
    }

    private var listenTask: Task<Void, Never>?

    /// Pretends the child finished speaking after 0.8 s.
    func startListening(expecting: [String], onHeard: @escaping @MainActor (String) -> Void) {
        listenTask?.cancel()
        let text = heardText ?? expecting.first ?? ""
        listenTask = Task {
            try? await Task.sleep(for: .milliseconds(800))
            guard !Task.isCancelled else { return }
            onHeard(text)
        }
    }

    func stopListening() {
        listenTask?.cancel()
        listenTask = nil
    }
}
