import Foundation
import CoreGraphics
import Observation

/// "Meet the instruments": before the game, every instrument plays its sound once, one
/// after another, so the child knows what each one sounds like before being asked.
///
///   screen opens → each sound plays in turn ("This is the guitar") → ticked as heard
///   all four heard → short pause → "You heard them all!" → Start the game
/// The child can tap a picture any time to hear it again. Figma: "L1–L4 · Learn".
@Observable
@MainActor
final class LearnSoundsViewModel {
    /// Everything one picture needs, already worked out for the View.
    struct Item: Identifiable {
        enum State { case new, playing, heard }
        let id: String
        let label: String
        let art: String?
        let artFrame: CGRect
        let ground: IdentificationScene.Ground
        let labelCenter: CGPoint
        let state: State
    }

    private(set) var heard: Set<String> = []
    private(set) var playingId: String?
    /// True while the sounds play one after another, including the pause after the last one.
    private(set) var isAutoPlaying = false
    private var hasAutoPlayed = false

    private let options: [Option]
    private let scene: IdentificationScene
    private let audio: any AudioPlaybackService
    private let router: AppRouter
    private let onFinished: () -> Void
    /// Goes up whenever a sound starts or stops, so a sound that ends late is ignored.
    private var playbackId = 0

    init(
        options: [Option],
        scene: IdentificationScene,
        audio: any AudioPlaybackService,
        router: AppRouter,
        onFinished: @escaping () -> Void
    ) {
        self.options = options
        self.scene = scene
        self.audio = audio
        self.router = router
        self.onFinished = onFinished
    }

    // MARK: - Text

    var headerText: String { "Learn the sounds" }

    var title: String {
        if let name = playingName { return "This is the \(name.lowercased())" }
        if allHeard { return "You heard them all!" }
        return "Meet the \(scene.noun)s"
    }

    var helper: String {
        if playingId != nil { return "Listen to how it sounds…" }
        if allHeard { return "Tap an instrument to hear its sound again." }
        if isAutoPlaying { return "Listen to each \(scene.noun)…" }
        return "Tap each \(scene.noun) to hear its sound."
    }

    // MARK: - Progress

    var heardCount: Int { heard.count }
    var total: Int { options.count }

    var progressCaption: String {
        allHeard ? "All \(total) heard" : "\(heardCount) of \(total) heard"
    }

    /// Start the game appears once every sound has been heard and nothing is playing.
    var showsStart: Bool { allHeard && playingId == nil && !isAutoPlaying }

    // MARK: - Pictures

    var items: [Item] {
        options.compactMap { option in
            guard let slot = scene.slots[option.id] else { return nil }
            let state: Item.State
            if playingId == option.id {
                state = .playing
            } else if heard.contains(option.id) {
                state = .heard
            } else {
                state = .new
            }
            return Item(id: option.id, label: option.label, art: slot.art,
                        artFrame: slot.artFrame, ground: slot.ground,
                        labelCenter: slot.labelCenter, state: state)
        }
    }

    // MARK: - Actions

    /// Plays every sound once, one after another, the first time the screen opens.
    /// After the last one there's a short pause before Start the game appears.
    func startAutoPlay() {
        guard !hasAutoPlayed else { return }
        hasAutoPlayed = true
        playbackId += 1
        let id = playbackId
        isAutoPlaying = true
        Task {
            try? await Task.sleep(for: .seconds(0.8))       // let the screen settle first
            for option in options {
                guard id == playbackId else { return }
                playingId = option.id
                heard.insert(option.id)
                await play(option)
                guard id == playbackId else { return }
                playingId = nil
                try? await Task.sleep(for: .seconds(0.6))   // short gap between instruments
            }
            try? await Task.sleep(for: .seconds(1.5))       // pause before Start the game
            guard id == playbackId else { return }
            isAutoPlaying = false
        }
    }

    /// Plays that picture's sound. It stops whatever was playing, including the
    /// one-after-another sounds; any instrument not heard yet can still be tapped.
    func itemTapped(_ optionId: String) {
        guard let option = options.first(where: { $0.id == optionId }) else { return }
        playbackId += 1
        let id = playbackId
        isAutoPlaying = false
        playingId = optionId
        heard.insert(optionId)
        Task {
            await play(option)
            guard id == playbackId else { return }
            playingId = nil
        }
    }

    func startTapped() {
        stopAll()
        onFinished()
    }

    func backTapped() {
        stopAll()
        router.presentLeavePractice()
    }

    func stopAll() {
        playbackId += 1
        audio.stop()
        playingId = nil
        isAutoPlaying = false
    }

    // MARK: - Private

    private var allHeard: Bool { !options.isEmpty && heard.count == options.count }

    private func play(_ option: Option) async {
        if let clip = option.audio {
            await audio.play(clip)
        } else {
            try? await Task.sleep(for: .seconds(2))
        }
    }

    private var playingName: String? {
        options.first { $0.id == playingId }?.label
    }
}
