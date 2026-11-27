import Foundation
import CoreGraphics
import Observation

/// Identification game: hear a sound, tap the picture that made it.
/// Used by every Identification exercise (Instruments, Animals, Nature, Objects).
///
/// One round:
///   ready ("Tap play") → playing → choosing ("Tap the instrument you heard.")
///   wrong pick → red outline, "Not quite — try again!" → choose again (or replay)
///   right pick → green outline, "That’s right! Great listening." → next round
/// After the last round the score is saved and the shared completion screen opens.
@Observable
@MainActor
final class PictureChoiceViewModel {
    enum Phase: Equatable {
        case ready
        case playing(replay: Bool)
        case choosing
        case wrong(optionId: String)
        case correct
    }

    /// Everything one picture on the meadow needs, already worked out for the View.
    struct Picture: Identifiable {
        enum Highlight { case none, correct, wrong }
        let id: String
        let label: String
        let art: String?
        let artFrame: CGRect
        let ground: IdentificationScene.Ground
        let highlight: Highlight
        let canTap: Bool
    }

    /// What sits in the round button area above the question.
    enum AudioControl { case play, listening, replay }

    /// Colour of the line under the question.
    enum HelperTone { case normal, wrong, correct }

    private(set) var phase: Phase = .ready
    private(set) var roundIndex = 0
    /// The "Meet the instruments" step shown before the first question; nil once it's done
    /// (or for exercises without one).
    private(set) var learning: LearnSoundsViewModel?

    private let exerciseId: String
    private let items: [ExerciseItem]
    private let audio: any AudioPlaybackService
    private let progress: any ProgressRepository
    private let router: AppRouter

    /// Rounds the child got right on the first try.
    private var firstTryCorrect = 0
    private var missedThisRound = false
    /// Goes up whenever a sound starts or is stopped, so a sound that finishes
    /// late can't change the screen afterwards.
    private var playbackId = 0
    /// Same idea for the short pause after a right answer; goes up when the screen goes away.
    private var advanceId = 0

    init(
        exerciseId: String,
        content: any ContentRepository,
        audio: any AudioPlaybackService,
        progress: any ProgressRepository,
        router: AppRouter
    ) {
        self.exerciseId = exerciseId
        self.items = content.exercise(id: exerciseId)?.items ?? []
        self.audio = audio
        self.progress = progress
        self.router = router

        let firstOptions = items.first?.options ?? []
        let scene = IdentificationScene.forExercise(exerciseId, optionIds: firstOptions.map(\.id))
        if scene.teachesSounds {
            learning = LearnSoundsViewModel(
                options: firstOptions,
                scene: scene,
                audio: audio,
                router: router,
                onFinished: { [weak self] in self?.learning = nil }
            )
        }
    }

    // MARK: - Question card

    var progressText: String {
        "Question \(roundIndex + 1) of \(max(items.count, 1))"
    }

    var title: String {
        currentItem?.prompt ?? "Which one did you hear?"
    }

    var helper: String {
        switch phase {
        case .ready: return "Tap play to hear the sound."
        case .playing: return "Listening…"
        case .choosing: return "Tap the \(scene.noun) you heard."
        case .wrong: return "Not quite — try again!"
        case .correct: return "That’s right! Great listening."
        }
    }

    var helperTone: HelperTone {
        switch phase {
        case .wrong: return .wrong
        case .correct: return .correct
        default: return .normal
        }
    }

    var audioControl: AudioControl {
        switch phase {
        case .ready: return .play
        case .playing: return .listening
        case .choosing, .wrong, .correct: return .replay
        }
    }

    /// Replay works while the child is choosing; not while a sound plays or after the right answer.
    var canPlay: Bool {
        switch phase {
        case .ready, .choosing, .wrong: return true
        default: return false
        }
    }

    // MARK: - Pictures on the meadow

    var pictures: [Picture] {
        options.compactMap { option in
            guard let slot = scene.slots[option.id] else { return nil }
            let highlight: Picture.Highlight
            switch phase {
            case .wrong(let picked) where picked == option.id: highlight = .wrong
            case .correct where option.id == answerId: highlight = .correct
            default: highlight = .none
            }
            return Picture(
                id: option.id,
                label: option.label,
                art: slot.art,
                artFrame: slot.artFrame,
                ground: slot.ground,
                highlight: highlight,
                canTap: canChoose && phase != .wrong(optionId: option.id)
            )
        }
    }

    // MARK: - Actions

    func playTapped() {
        guard canPlay else { return }
        playbackId += 1
        let id = playbackId
        phase = .playing(replay: phase != .ready)
        Task { await playSound(id: id) }
    }

    func pictureTapped(_ optionId: String) {
        guard canChoose, phase != .wrong(optionId: optionId) else { return }
        if optionId == answerId {
            if !missedThisRound { firstTryCorrect += 1 }
            phase = .correct
            moveOnAfterCelebrating()
        } else {
            missedThisRound = true
            phase = .wrong(optionId: optionId)
        }
    }

    /// Back button: stops the sound and asks "Leave this practice?" using the shared overlay.
    /// After a right answer the round is already won, so moving on isn't cancelled.
    func backTapped() {
        stopSound()
        router.presentLeavePractice()
    }

    /// The screen went away: stop the sound and anything still waiting to happen.
    func stopAll() {
        advanceId += 1
        stopSound()
        learning?.stopAll()
    }

    // MARK: - Private

    private var currentItem: ExerciseItem? {
        items.indices.contains(roundIndex) ? items[roundIndex] : nil
    }

    private var options: [Option] { currentItem?.options ?? [] }
    private var answerId: String { currentItem?.correctOptionId ?? "" }

    private var scene: IdentificationScene {
        IdentificationScene.forExercise(exerciseId, optionIds: options.map(\.id))
    }

    private var canChoose: Bool {
        switch phase {
        case .choosing, .wrong: return true
        default: return false
        }
    }

    private func stopSound() {
        playbackId += 1
        audio.stop()
        if case .playing(let replay) = phase {
            phase = replay ? .choosing : .ready
        }
    }

    private func playSound(id: Int) async {
        if let clip = currentItem?.audio {
            await audio.play(clip)
        } else {
            try? await Task.sleep(for: .seconds(2))
        }
        // Only move on if this is still the latest sound and nobody left the screen.
        guard id == playbackId, case .playing = phase else { return }
        phase = .choosing
    }

    /// Keeps the green outline on screen for a moment, then opens the next round
    /// or, after the last one, saves the score and shows the completion screen.
    private func moveOnAfterCelebrating() {
        advanceId += 1
        let id = advanceId
        Task {
            try? await Task.sleep(for: .seconds(1.6))
            guard id == advanceId, phase == .correct else { return }
            if roundIndex >= items.count - 1 {
                let outcome = progress.finish(exerciseId: exerciseId, correct: firstTryCorrect, total: items.count)
                router.go(.completion(exerciseId: exerciseId, outcome: outcome))
            } else {
                roundIndex += 1
                missedThisRound = false
                phase = .ready
            }
        }
    }
}
