import Foundation
import Observation

@Observable
@MainActor
final class StoryPlayerViewModel {

    enum State: Equatable {
        case loading
        case listening(pageIndex: Int)
        case storyFinished
        case ordering
        case matching
        case complete(allCorrectFirstTime: Bool)
        case error(String)
    }

    enum Playback: Equatable {
        case ready
        case playing
        case paused
        case finished
    }

    struct Page: Identifiable, Hashable {
        let id: String
        let text: String
        let image: String
        let audio: String
    }

    let exerciseId: String
    private(set) var state: State = .loading
    private(set) var playback: Playback = .ready
    private(set) var pages: [Page] = []
    private(set) var ordering: OrderingViewModel?
    private(set) var matching: MatchingViewModel?

    private(set) var playbackFraction: Double = 0
    private(set) var speed: NarrationSpeed = .normal
    private(set) var hasHeardPage = false
    private(set) var errorMessage: String?
    private var isDraggingSlider = false

    private let content: any ContentRepository
    private let narrator: any StoryNarrationService
    private let progress: any ProgressRepository
    private let router: AppRouter
    private var correctFirstTime = 0

    init(
        exerciseId: String,
        content: any ContentRepository,
        narrator: any StoryNarrationService,
        progress: any ProgressRepository,
        router: AppRouter
    ) {
        self.exerciseId = exerciseId
        self.content = content
        self.narrator = narrator
        self.progress = progress
        self.router = router
        narrator.onEvent = { [weak self] event in
            self?.handle(event)
        }
        load()
    }

    // MARK: - Shown on screen

    var currentPage: Page? {
        guard case .listening(let index) = state, pages.indices.contains(index) else { return nil }
        return pages[index]
    }

    var isOnStoryPage: Bool {
        currentPage != nil
    }

    var durationText: String {
        Self.timeText(storyDuration)
    }

    var elapsedText: String {
        Self.timeText(storyDuration * playbackFraction)
    }

    /// Next appears once the page has been heard to the end (or the sound failed).
    var canGoNext: Bool {
        hasHeardPage
    }

    var questionLabel: String? {
        let total = questionCount
        switch state {
        case .ordering:
            return "Question 1 of \(total)"
        case .matching:
            return "Question \(ordering == nil ? 1 : 2) of \(total)"
        default:
            return nil
        }
    }

    // MARK: - User actions

    /// The round button on the audio bar: play, pause, resume or listen again.
    func didTapPlay() {
        guard let page = currentPage else { return }
        errorMessage = nil
        switch playback {
        case .ready:
            narrator.speak(page.text, from: playbackFraction, speed: speed)
        case .playing:
            narrator.pause()
        case .paused:
            narrator.resume()
        case .finished:
            playbackFraction = 0
            narrator.speak(page.text, from: 0, speed: speed)
        }
    }

    /// A new speed applies straight away, from the sentence being read.
    func didSelectSpeed(_ newSpeed: NarrationSpeed) {
        guard newSpeed != speed else { return }
        speed = newSpeed
        guard let page = currentPage else { return }
        switch playback {
        case .playing:
            narrator.speak(page.text, from: playbackFraction, speed: speed)
        case .paused:
            narrator.stop()
            playback = .ready
        case .ready, .finished:
            break
        }
    }

    func didDragSlider(to fraction: Double) {
        isDraggingSlider = true
        playbackFraction = min(max(fraction, 0), 1)
    }

    /// Letting go of the slider reads on from the sentence under the thumb.
    func didReleaseSlider() {
        isDraggingSlider = false
        guard let page = currentPage else { return }
        narrator.speak(page.text, from: playbackFraction, speed: speed)
    }

    func didTapNext() {
        guard case .listening(let index) = state, canGoNext else { return }
        narrator.stop()
        resetPlayback()
        state = index + 1 < pages.count ? .listening(pageIndex: index + 1) : .storyFinished
    }

    /// Called when the story page goes away (back button, or moving on).
    func didLeaveStoryPage() {
        narrator.stop()
        if playback == .playing || playback == .paused {
            playback = .ready
        }
    }

    func dismissError() {
        errorMessage = nil
    }

    func didTapStartQuestions() {
        if ordering != nil {
            state = .ordering
        } else if matching != nil {
            state = .matching
        } else {
            finish()
        }
    }

    // MARK: - Private

    private var storyDuration: TimeInterval {
        guard let page = currentPage else { return 0 }
        return narrator.estimatedDuration(of: page.text, speed: speed)
    }

    private static func timeText(_ seconds: TimeInterval) -> String {
        Duration.seconds(seconds.rounded()).formatted(.time(pattern: .minuteSecond))
    }

    private func handle(_ event: NarrationEvent) {
        switch event {
        case .started, .resumed:
            playback = .playing
        case .progress(let fraction):
            if !isDraggingSlider {
                playbackFraction = fraction
            }
        case .paused:
            if playback == .playing {
                playback = .paused
            }
        case .finished:
            playback = .finished
            playbackFraction = 1
            hasHeardPage = true
        case .failed(let message):
            playback = .ready
            errorMessage = message
            hasHeardPage = true
        }
    }

    private func resetPlayback() {
        playback = .ready
        playbackFraction = 0
        hasHeardPage = false
    }

    private var questionCount: Int {
        (ordering == nil ? 0 : 1) + (matching == nil ? 0 : 1)
    }

    private func load() {
        guard let exercise = content.exercise(id: exerciseId) else {
            state = .error("This story could not be found.")
            return
        }

        pages = exercise.items
            .filter { $0.options == nil }
            .map { Page(id: $0.id, text: $0.text ?? "", image: $0.image ?? "", audio: $0.audio ?? "") }

        if let item = exercise.items.first(where: { $0.id.hasSuffix(StoryItemSuffix.ordering) }) {
            ordering = OrderingViewModel(item: item) { [weak self] correct in
                self?.questionDone(correct: correct, next: .matching)
            }
        }

        if let question = exercise.items.first(where: { $0.id.hasSuffix(StoryItemSuffix.matching) }),
           let answers = exercise.items.first(where: { $0.id.hasSuffix(StoryItemSuffix.matchingAnswers) }) {
            matching = MatchingViewModel(question: question, answers: answers) { [weak self] correct in
                self?.questionDone(correct: correct, next: nil)
            }
        }

        // Before you start already explains the story, so it opens on the first page.
        state = pages.isEmpty ? .storyFinished : .listening(pageIndex: 0)
    }

    private func questionDone(correct: Bool, next: State?) {
        if correct { correctFirstTime += 1 }
        if next == .matching, matching != nil {
            state = .matching
        } else {
            finish()
        }
    }

    /// Saves the score and opens the shared completion screen.
    private func finish() {
        let total = max(questionCount, 1)
        let outcome = progress.finish(exerciseId: exerciseId, correct: correctFirstTime, total: total)
        state = .complete(allCorrectFirstTime: correctFirstTime == total)
        router.go(.completion(exerciseId: exerciseId, outcome: outcome))
    }

    /// Back button: stops the narration and opens the shared "Leave this practice?" overlay.
    func didTapBack() {
        didLeaveStoryPage()
        router.presentLeavePractice()
    }
}
