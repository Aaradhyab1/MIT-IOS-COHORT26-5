import AVFoundation

/// Reads a story aloud with `AVSpeechSynthesizer`, one sentence per utterance so the
/// child gets a short pause between sentences and the reader can restart at any sentence.
@MainActor
final class SpeechStoryNarrationService: NSObject, StoryNarrationService {
    var onEvent: ((NarrationEvent) -> Void)?

    private var synthesizer = AVSpeechSynthesizer()
    private var voice: AVSpeechSynthesisVoice?

    private var text = ""
    private var speed: NarrationSpeed = .normal
    private var sentences: [StorySentence] = []
    private var totalLength = 1
    /// Utterances still to be spoken, by identity, mapped to their sentence index.
    private var queued: [ObjectIdentifier: Int] = [:]
    /// Keeps the queued utterances alive so their identities stay unique.
    private var utterances: [AVSpeechUtterance] = []
    private var currentIndex = 0
    private var hasReportedStart = false

    nonisolated(unsafe) private var observers: [NSObjectProtocol] = []

    override init() {
        super.init()
        voice = Self.storytellerVoice()
        synthesizer.delegate = self
        observeAudioSession()
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - StoryNarrationService

    func speak(_ text: String, from fraction: Double, speed: NarrationSpeed) {
        cancelQueue()
        self.text = text
        self.speed = speed
        sentences = StoryText.sentences(in: text)
        totalLength = max(text.utf16.count, 1)

        guard !sentences.isEmpty else {
            onEvent?(.finished)
            return
        }

        do {
            try activateAudioSession()
        } catch {
            onEvent?(.failed("The story can't play right now. Check the sound and try again."))
            return
        }

        let target = Int(Double(totalLength) * min(max(fraction, 0), 1))
        let first = sentences.lastIndex { $0.offset <= target } ?? 0
        currentIndex = first
        hasReportedStart = false

        for index in first..<sentences.count {
            let utterance = AVSpeechUtterance(string: sentences[index].text)
            utterance.voice = voice
            utterance.rate = speed.rate
            utterance.pitchMultiplier = 1.1
            utterance.postUtteranceDelay = StoryText.pauseAfterSentence
            utterances.append(utterance)
            queued[ObjectIdentifier(utterance)] = index
            synthesizer.speak(utterance)
        }
        onEvent?(.progress(Double(sentences[first].offset) / Double(totalLength)))
    }

    func pause() {
        guard isReading else { return }
        if synthesizer.isSpeaking && !synthesizer.isPaused {
            _ = synthesizer.pauseSpeaking(at: .word)
        } else {
            onEvent?(.paused)
        }
    }

    func resume() {
        guard isReading else { return }
        if synthesizer.isPaused {
            do {
                try activateAudioSession()
            } catch {
                onEvent?(.failed("The story can't play right now. Check the sound and try again."))
                return
            }
            _ = synthesizer.continueSpeaking()
        } else {
            // The system stopped the speech (for example after a call): start the sentence again.
            let fraction = Double(sentences[currentIndex].offset) / Double(totalLength)
            speak(text, from: fraction, speed: speed)
        }
    }

    func stop() {
        cancelQueue()
        deactivateAudioSession()
    }

    // MARK: - Private

    private var isReading: Bool {
        !queued.isEmpty
    }

    private func cancelQueue() {
        queued.removeAll()
        utterances.removeAll()
        if synthesizer.isSpeaking || synthesizer.isPaused {
            _ = synthesizer.stopSpeaking(at: .immediate)
        }
    }

    /// `.playback` keeps the story audible with the silent switch on; `.spokenAudio`
    /// tells the system this is speech, so other apps pause instead of mixing.
    private func activateAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .spokenAudio)
        try session.setActive(true)
    }

    private func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// The best English voice on the device: highest quality first, then the device's
    /// own English (for example en-IN), then US English. Novelty and personal voices are skipped.
    private static func storytellerVoice() -> AVSpeechSynthesisVoice? {
        let deviceLanguage = AVSpeechSynthesisVoice.currentLanguageCode()
        let candidates = AVSpeechSynthesisVoice.speechVoices().filter { voice in
            voice.language.hasPrefix("en")
                && !voice.voiceTraits.contains(.isNoveltyVoice)
                && !voice.voiceTraits.contains(.isPersonalVoice)
        }
        func score(_ voice: AVSpeechSynthesisVoice) -> Int {
            var score = voice.quality.rawValue * 10
            if voice.language == deviceLanguage {
                score += 5
            } else if voice.language == "en-US" {
                score += 2
            }
            return score
        }
        return candidates.max { score($0) < score($1) } ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    // MARK: - Synthesizer callbacks

    private func utteranceStarted(_ id: ObjectIdentifier) {
        guard let index = queued[id] else { return }
        currentIndex = index
        if !hasReportedStart {
            hasReportedStart = true
            onEvent?(.started)
        }
    }

    private func willSpeak(_ id: ObjectIdentifier, at location: Int) {
        guard let index = queued[id] else { return }
        let spoken = sentences[index].offset + location
        onEvent?(.progress(min(Double(spoken) / Double(totalLength), 1)))
    }

    private func utteranceFinished(_ id: ObjectIdentifier) {
        guard let index = queued.removeValue(forKey: id) else { return }
        if index == sentences.count - 1 {
            utterances.removeAll()
            deactivateAudioSession()
            onEvent?(.progress(1))
            onEvent?(.finished)
        }
    }

    private func reportIfReading(_ event: NarrationEvent) {
        if isReading {
            onEvent?(event)
        }
    }

    // MARK: - Audio session

    private func observeAudioSession() {
        let center = NotificationCenter.default
        let session = AVAudioSession.sharedInstance()

        observers.append(center.addObserver(
            forName: AVAudioSession.interruptionNotification, object: session, queue: .main
        ) { [weak self] note in
            let rawType = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
            MainActor.assumeIsolated { self?.handleInterruption(rawType) }
        })

        observers.append(center.addObserver(
            forName: AVAudioSession.routeChangeNotification, object: session, queue: .main
        ) { [weak self] note in
            let rawReason = note.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt
            MainActor.assumeIsolated { self?.handleRouteChange(rawReason) }
        })

        observers.append(center.addObserver(
            forName: AVAudioSession.mediaServicesWereResetNotification, object: session, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.handleMediaServicesReset() }
        })
    }

    /// A call, Siri or an alarm takes the audio: pause and wait for the child to tap play.
    private func handleInterruption(_ rawType: UInt?) {
        guard let rawType, let type = AVAudioSession.InterruptionType(rawValue: rawType) else { return }
        if type == .began {
            pause()
        }
    }

    /// Headphones or a hearing-aid stream disconnected: pause rather than play out loud.
    private func handleRouteChange(_ rawReason: UInt?) {
        guard let rawReason, AVAudioSession.RouteChangeReason(rawValue: rawReason) == .oldDeviceUnavailable else { return }
        pause()
    }

    /// The system's audio server restarted: the old synthesizer no longer works.
    private func handleMediaServicesReset() {
        let wasReading = isReading
        queued.removeAll()
        utterances.removeAll()
        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        if wasReading {
            onEvent?(.failed("The sound stopped. Tap play to start the story again."))
        }
    }
}

extension SpeechStoryNarrationService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor [weak self] in self?.utteranceStarted(id) }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        willSpeakRangeOfSpeechString characterRange: NSRange,
        utterance: AVSpeechUtterance
    ) {
        let id = ObjectIdentifier(utterance)
        let location = characterRange.location
        Task { @MainActor [weak self] in self?.willSpeak(id, at: location) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor [weak self] in self?.utteranceFinished(id) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in self?.reportIfReading(.paused) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor [weak self] in self?.reportIfReading(.resumed) }
    }
}
