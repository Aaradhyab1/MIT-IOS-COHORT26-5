import Foundation
import Testing
@testable import EchoProject

struct ReadingTrackerTests {
    private let words = ["every", "morning", "i", "wake", "up", "early"]

    @Test func movesForwardAsWordsAreHeard() {
        var tracker = ReadingTracker(words: words)
        tracker.beginSession()

        tracker.update(heard: "Every morning")

        #expect(tracker.position == 2)
        #expect(tracker.skipped.isEmpty)
    }

    @Test func acceptsCloseWords() {
        var tracker = ReadingTracker(words: ["i", "brush", "my", "teeth"])
        tracker.beginSession()

        tracker.update(heard: "I brush my tooth")

        #expect(tracker.isFinished)
        #expect(tracker.correctCount == 4)
    }

    @Test func skipsAWordTheRecogniserMissed() {
        var tracker = ReadingTracker(words: words)
        tracker.beginSession()

        tracker.update(heard: "every I wake")

        #expect(tracker.position == 4)
        #expect(tracker.skipped == [1])
        #expect(tracker.correctCount == 3)
    }

    @Test func neverMovesBackwards() {
        var tracker = ReadingTracker(words: words)
        tracker.beginSession()
        tracker.update(heard: "every morning I")

        tracker.update(heard: "every")   // the recogniser changed its mind

        #expect(tracker.position == 3)
    }

    @Test func resumingCountsFromWhereTheChildStopped() {
        var tracker = ReadingTracker(words: words)
        tracker.beginSession()
        tracker.update(heard: "every morning")

        tracker.beginSession()
        tracker.update(heard: "I wake up early")

        #expect(tracker.isFinished)
        #expect(tracker.skipped.isEmpty)
    }

    @Test func shortWordsMustMatchExactly() {
        #expect(!ReadingTracker.matches("a", "i"))
        #expect(ReadingTracker.matches("i", "i"))
    }
}

struct ReadingPassageTests {
    @Test func splitsTextIntoWordsWithSyllables() {
        let item = ExerciseItem(
            id: "p", text: "Every morning, I wake",
            options: [Option(id: "morning", label: "MOR-ning")]
        )

        let passage = ReadingPassage(item: item)

        #expect(passage.words.map(\.text) == ["Every", "morning,", "I", "wake"])
        #expect(passage.words[1].spoken == "morning")
        #expect(passage.words[1].syllables == "MOR-ning")
        #expect(passage.words[3].syllables == "WAKE")
        #expect(passage.text(from: 2) == "I wake")
    }
}

@MainActor
struct SentencesPracticeViewModelTests {
    private func makeViewModel(
        exerciseId: String = "sentences.two-word",
        reader: DummyReadAloudService = DummyReadAloudService(wordInterval: .zero),
        router: AppRouter = AppRouter(isOnboardingComplete: true)
    ) -> SentencesPracticeViewModel {
        let content = InMemoryContentRepository()
        return SentencesPracticeViewModel(
            exerciseId: exerciseId,
            content: content,
            reader: reader,
            voice: DummySpeechSynthesisService(),
            progress: InMemoryProgressRepository(content: content),
            router: router
        )
    }

    /// Waits until the pretend reader has finished the passage.
    private func waitForPassage(_ vm: SentencesPracticeViewModel) async {
        for _ in 0..<200 where vm.phase != .passageDone {
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    @Test func everyCategoryHasPassages() {
        let content = InMemoryContentRepository()
        let level = content.levels(for: .speaking).first { $0.id == "speaking.sentences" }

        #expect(level?.exerciseIds.count == 4)
        for id in level?.exerciseIds ?? [] {
            #expect(content.exercise(id: id)?.items.isEmpty == false)
        }
    }

    @Test func startsIdleWithNothingHighlighted() {
        let vm = makeViewModel()

        #expect(vm.phase == .idle)
        #expect(vm.positionText == "Sentence 1 of 4")
        #expect(vm.words.map(\.text) == ["Big", "dog."])
        #expect(vm.words.allSatisfy { vm.highlight(for: $0) == .none })
    }

    @Test func readingAloudHighlightsEveryWord() async {
        let vm = makeViewModel()

        vm.didTapMicrophone()
        await waitForPassage(vm)

        #expect(vm.phase == .passageDone)
        #expect(vm.words.allSatisfy { vm.highlight(for: $0) == .read })
    }

    @Test func theMicrophonePausesAndResumes() async {
        let vm = makeViewModel(reader: DummyReadAloudService(wordInterval: .seconds(5)))

        vm.didTapMicrophone()
        for _ in 0..<100 where vm.phase != .reading { try? await Task.sleep(for: .milliseconds(10)) }
        #expect(vm.phase == .reading)

        vm.didTapMicrophone()
        #expect(vm.phase == .paused)
        #expect(vm.status == "Tap to continue reading")
    }

    @Test func tappingAWordPausesAndOpensTheSheet() async throws {
        let vm = makeViewModel(reader: DummyReadAloudService(wordInterval: .seconds(5)))
        vm.didTapMicrophone()
        for _ in 0..<100 where vm.phase != .reading { try? await Task.sleep(for: .milliseconds(10)) }

        let dog = try #require(vm.words.last)
        vm.didTapWord(dog)

        #expect(vm.phase == .paused)
        #expect(vm.selectedWord?.spoken == "dog")
        vm.didCloseSheet()
        #expect(vm.selectedWord == nil)
    }

    @Test func refusedMicrophoneShowsTheRecoveryState() async {
        let reader = DummyReadAloudService(wordInterval: .zero)
        reader.allowsMicrophone = false
        let vm = makeViewModel(reader: reader)

        vm.didTapMicrophone()
        for _ in 0..<100 where vm.phase == .idle { try? await Task.sleep(for: .milliseconds(10)) }

        #expect(vm.phase == .micDenied)
    }

    @Test func finishingEveryPassageOpensTheCompletionScreen() async {
        let router = AppRouter(isOnboardingComplete: true)
        let vm = makeViewModel(exerciseId: "sentences.expanding", router: router)

        for _ in 0..<3 {
            vm.didTapMicrophone()
            await waitForPassage(vm)
            vm.didTapNext()
        }

        #expect(router.speakingPath.count == 1)
    }
}
