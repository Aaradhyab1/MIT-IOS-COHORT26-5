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
        voice = VoiceSettings.storytellerVoice()
        synthesizer.delegate = self
        observeAudioSession()
        observeVoiceDownloads()
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
            VoiceSettings.apply(to: utterance, voice: voice, speed: speed)
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

    /// A voice finished downloading (for example Isha Premium from Settings): switch to it
    /// for the next sentence the child hears.
    private func observeVoiceDownloads() {
        observers.append(NotificationCenter.default.addObserver(
            forName: AVSpeechSynthesizer.availableVoicesDidChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.voice = VoiceSettings.storytellerVoice() }
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

// MARK: - Voice settings

extension SpeechStoryNarrationService {
    /// The one place that decides how every story sounds, so all stories use the same
    /// voice, pace and pitch.
    ///
    /// Voice order (Indian English, built into iOS, no downloads from the internet by the app):
    /// 1. Isha (Premium)   2. Isha (Enhanced)   3. Sangeeta (Enhanced)
    /// 4. the best other en-IN voice on the device   5. the system's default en-IN, then en-US voice.
    /// Premium and Enhanced voices appear once the family downloads them in
    /// Settings › Accessibility › Spoken Content › Voices › English (India).
    enum VoiceSettings {
        enum Quality: Int, Comparable {
            case standard = 1
            case enhanced = 2
            case premium = 3

            static func < (lhs: Quality, rhs: Quality) -> Bool { lhs.rawValue < rhs.rawValue }
        }

        struct Preference: Equatable {
            let name: String
            let quality: Quality
        }

        /// What the app needs to know about an installed voice to choose between them.
        struct Candidate: Equatable {
            let identifier: String
            let name: String
            let language: String
            let quality: Quality
        }

        static let language = "en-IN"

        static let preferences: [Preference] = [
            Preference(name: "Isha", quality: .premium),
            Preference(name: "Isha", quality: .enhanced),
            Preference(name: "Sangeeta", quality: .enhanced)
        ]

        /// A little slower than the chosen speed, so 5–8 year olds can follow every word.
        static let kidsPace: Float = 0.94
        /// A touch brighter than a neutral voice, without sounding cartoonish.
        static let pitch: Float = 1.05
        /// A breath before each sentence, so sentences never run into each other.
        static let pauseBeforeSentence: TimeInterval = 0.08

        /// Picks the narrator from the installed voices, following `preferences`.
        static func choose(from candidates: [Candidate]) -> Candidate? {
            let indian = candidates.filter { $0.language == language }
            for preference in preferences {
                if let match = indian.first(where: { matches($0, preference.name) && $0.quality == preference.quality }) {
                    return match
                }
            }
            return indian.max { $0.quality < $1.quality }
        }

        static func storytellerVoice() -> AVSpeechSynthesisVoice? {
            let installed = AVSpeechSynthesisVoice.speechVoices().filter { voice in
                !voice.voiceTraits.contains(.isNoveltyVoice) && !voice.voiceTraits.contains(.isPersonalVoice)
            }
            let candidates = installed.map { voice in
                Candidate(
                    identifier: voice.identifier,
                    name: voice.name,
                    language: voice.language,
                    quality: Quality(rawValue: voice.quality.rawValue) ?? .standard
                )
            }
            let chosen = choose(from: candidates).flatMap { AVSpeechSynthesisVoice(identifier: $0.identifier) }
                ?? AVSpeechSynthesisVoice(language: language)
                ?? AVSpeechSynthesisVoice(language: "en-US")
            #if DEBUG
            print("Story narrator voice:", chosen?.name ?? "system default", chosen?.identifier ?? "")
            #endif
            return chosen
        }

        static func apply(to utterance: AVSpeechUtterance, voice: AVSpeechSynthesisVoice?, speed: NarrationSpeed) {
            utterance.voice = voice
            utterance.rate = speed.rate * kidsPace
            utterance.pitchMultiplier = pitch
            utterance.preUtteranceDelay = pauseBeforeSentence
            utterance.postUtteranceDelay = StoryText.pauseAfterSentence
        }

        /// Names can carry a suffix on some iOS versions ("Isha (Premium)"), and the
        /// identifier always ends in the voice's name (com.apple.voice.premium.en-IN.Isha).
        private static func matches(_ candidate: Candidate, _ name: String) -> Bool {
            candidate.name.lowercased().hasPrefix(name.lowercased())
                || candidate.identifier.lowercased().hasSuffix("." + name.lowercased())
        }
    }
}
