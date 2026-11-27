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

    @Test func onlyExactWordsLightUp() {
        var tracker = ReadingTracker(words: ["i", "brush", "my", "teeth"])
        tracker.beginSession()

        tracker.update(heard: "I brush my tooth")

        #expect(tracker.position == 3)      // "tooth" is not "teeth"
        #expect(!tracker.isFinished)
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

    /// Waits until the pretend reader has finished the passage and its score shows.
    private func waitForPassage(_ vm: SentencesPracticeViewModel) async {
        for _ in 0..<200 where vm.result == nil {
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

        #expect(vm.result?.percent == 100)
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

    @Test func everyPassageShowsItsOwnAccuracy() async {
        let vm = makeViewModel(exerciseId: "sentences.expanding")

        for index in 0..<3 {
            vm.didTapMicrophone()
            await waitForPassage(vm)
            #expect(vm.result?.percent == 100)
            #expect(vm.continueTitle == (index < 2 ? "Next sentence" : "Back to home"))
            if index < 2 { vm.didTapContinue() }
        }
    }

    @Test func tryAgainResetsThePassage() async {
        let vm = makeViewModel(exerciseId: "sentences.expanding")
        vm.didTapMicrophone()
        await waitForPassage(vm)
        vm.didTapContinue()
        vm.didTapMicrophone()
        await waitForPassage(vm)

        vm.didTapTryAgain()

        #expect(vm.phase == .idle)
        #expect(vm.result == nil)
        #expect(vm.positionText == "Sentence 2 of 3")
        #expect(vm.words.allSatisfy { vm.highlight(for: $0) == .none })
    }
}

struct ReadingAccuracyTests {
    private let expected = ["the", "little", "cat", "sleeps"]

    @Test func everyWordSaidIsOneHundredPercent() {
        let heard = ReadingAccuracy.words(in: "The little cat sleeps.")
        #expect(ReadingAccuracy.correctWords(expected: expected, heard: heard) == 4)
        #expect(ReadingAccuracy.percent(correct: 4, total: 4) == 100)
    }

    @Test func capitalsAndPunctuationAreIgnored() {
        let heard = ReadingAccuracy.words(in: "THE, little! Cat sleeps?")
        #expect(ReadingAccuracy.correctWords(expected: expected, heard: heard) == 4)
    }

    @Test func aWordMustMatchLetterForLetter() {
        let heard = ReadingAccuracy.words(in: "the little cats sleep")
        #expect(ReadingAccuracy.correctWords(expected: expected, heard: heard) == 2)
    }

    @Test func aSkippedWordDoesNotShiftTheRest() {
        let heard = ReadingAccuracy.words(in: "the cat sleeps")
        #expect(ReadingAccuracy.correctWords(expected: expected, heard: heard) == 3)
    }

    @Test func repeatedAndExtraWordsAreNotCountedTwice() {
        let heard = ReadingAccuracy.words(in: "um the the little little cat cat sleeps sleeps yes")
        #expect(ReadingAccuracy.correctWords(expected: expected, heard: heard) == 4)
    }

    @Test func nothingHeardIsZero() {
        #expect(ReadingAccuracy.correctWords(expected: expected, heard: []) == 0)
        #expect(ReadingAccuracy.percent(correct: 0, total: 0) == 0)
    }

    @Test func tiersFollowThePercentage() {
        #expect(AccuracyTier(percent: 0) == .keepTrying)
        #expect(AccuracyTier(percent: 39) == .keepTrying)
        #expect(AccuracyTier(percent: 40) == .almostThere)
        #expect(AccuracyTier(percent: 69) == .almostThere)
        #expect(AccuracyTier(percent: 70) == .greatJob)
        #expect(AccuracyTier(percent: 89) == .greatJob)
        #expect(AccuracyTier(percent: 90) == .amazing)
        #expect(AccuracyTier(percent: 100) == .amazing)
    }

    @Test func tryAgainIsOfferedBelowNinetyPercent() {
        #expect(SentencesResult(correctWords: 17, totalWords: 20).tier.offersTryAgain)    // 85 %
        #expect(!SentencesResult(correctWords: 18, totalWords: 20).tier.offersTryAgain)   // 90 %
    }
}

struct HeardWordTests {
    @Test func anAlternativeSpellingCountsAsHeard() {
        let heard = [HeardWord(options: ["how"]), HeardWord(options: ["i"]),
                     HeardWord(options: ["wander", "wonder"])]
        #expect(ReadingAccuracy.correctWords(expected: ["how", "i", "wonder"], heard: heard) == 3)
    }

    @Test func theTrackerFollowsAlternativesToo() {
        var tracker = ReadingTracker(words: ["how", "i", "wonder"])
        tracker.beginSession()

        tracker.update(heard: [HeardWord(options: ["how"]), HeardWord(options: ["i"]),
                               HeardWord(options: ["wander", "wonder"])])

        #expect(tracker.isFinished)
    }
}
