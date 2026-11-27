import Foundation
import Testing
@testable import EchoProject

@MainActor
struct ReadingTrackerTests {
    private let words = ["every", "morning", "i", "wake", "up", "early"]

    @Test func movesForwardAsWordsAreHeard() {
        var tracker = ReadingTracker(words: words)

        tracker.align(heard: "Every morning")

        #expect(tracker.position == 2)
        #expect(tracker.matched == [0, 1])
        #expect(tracker.incorrect.isEmpty)
    }

    @Test func aWrongWordTurnsRedAndMovesOn() {
        var tracker = ReadingTracker(words: ["i", "brush", "my", "teeth"])

        tracker.align(heard: "I brush my tooth")

        #expect(tracker.isFinished)         // "tooth" is not "teeth", but reading goes on
        #expect(tracker.incorrect == [3])
        #expect(tracker.correctCount == 3)
    }

    @Test func aWrongFirstWordTurnsRedAndMovesOn() {
        var tracker = ReadingTracker(words: words)

        tracker.align(heard: "Avery")

        #expect(tracker.position == 1)
        #expect(tracker.incorrect == [0])
    }

    @Test func readingCarriesOnAfterAWrongFirstWord() {
        var tracker = ReadingTracker(words: words)

        tracker.align(heard: "Avery morning I wake up early")

        #expect(tracker.isFinished)
        #expect(tracker.incorrect == [0])
        #expect(tracker.correctCount == 5)
    }

    @Test func aWrongFirstWordCanBeCorrected() {
        var tracker = ReadingTracker(words: words)

        tracker.align(heard: "Avery every morning")

        #expect(tracker.position == 2)
        #expect(tracker.incorrect.isEmpty)
    }

    @Test func fillerSoundsDoNotCountAsWords() {
        var tracker = ReadingTracker(words: words)

        tracker.align(heard: "um every uh morning")

        #expect(tracker.position == 2)
        #expect(tracker.incorrect.isEmpty)
    }

    @Test func aSkippedWordTurnsRed() {
        var tracker = ReadingTracker(words: words)

        tracker.align(heard: "every I wake")

        #expect(tracker.position == 4)
        #expect(tracker.incorrect == [1])
        #expect(tracker.correctCount == 3)
    }

    @Test func sayingARedWordAgainCorrectsIt() {
        var tracker = ReadingTracker(words: words)

        tracker.align(heard: "every I morning wake up early")

        #expect(tracker.isFinished)
        #expect(tracker.incorrect.isEmpty)
        #expect(tracker.correctCount == 6)
    }

    @Test func repeatedAndExtraWordsDoNotShiftTheRest() {
        var tracker = ReadingTracker(words: words)

        tracker.align(heard: "um every every morning morning yes I wake up early")

        #expect(tracker.isFinished)
        #expect(tracker.correctCount == 6)
    }

    @Test func neverMovesBackwards() {
        var tracker = ReadingTracker(words: words)
        tracker.align(heard: "every morning I")

        tracker.align(heard: "every")   // the recogniser changed its mind

        #expect(tracker.position == 3)
    }

    @Test func resumingAfterAPauseKeepsProgress() {
        var tracker = ReadingTracker(words: words)
        tracker.align(heard: "every morning")

        // Everything heard in this passage: the first session, then the resumed one.
        tracker.align(heard: "every morning I wake up early")

        #expect(tracker.isFinished)
        #expect(tracker.incorrect.isEmpty)
    }

    @Test func shortWordsMustMatchExactly() {
        #expect(!HeardWord(options: ["a"]).matches("i"))
        #expect(HeardWord(options: ["i"]).matches("i"))
    }
}

@MainActor
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
        exerciseId: String = "sentences.simple-phrases",
        reader: DummyReadAloudService? = nil,
        router: AppRouter? = nil
    ) -> SentencesPracticeViewModel {
        let content = InMemoryContentRepository()
        return SentencesPracticeViewModel(
            exerciseId: exerciseId,
            content: content,
            reader: reader ?? DummyReadAloudService(wordInterval: .zero),
            voice: DummySpeechSynthesisService(),
            progress: InMemoryProgressRepository(content: content),
            router: router ?? AppRouter(isOnboardingComplete: true)
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

    @Test func theLibraryHasFourCategoriesInOrder() {
        let content = InMemoryContentRepository()
        let level = content.levels(for: .speaking).first { $0.id == "speaking.sentences" }

        #expect(level?.exerciseIds.compactMap { content.exercise(id: $0)?.title }
                == ["Simple Phrases", "Short Sentences", "Combined Sentences", "Paragraphs"])
    }

    @Test func noPassageAppearsTwice() {
        let content = InMemoryContentRepository()
        let level = content.levels(for: .speaking).first { $0.id == "speaking.sentences" }
        let texts = (level?.exerciseIds ?? []).flatMap { content.exercise(id: $0)?.items ?? [] }.compactMap(\.text)

        #expect(Set(texts).count == texts.count)
    }

    @Test func passagesGetLongerWithinEachCategory() {
        let content = InMemoryContentRepository()
        let level = content.levels(for: .speaking).first { $0.id == "speaking.sentences" }
        for id in level?.exerciseIds ?? [] {
            let counts = (content.exercise(id: id)?.items ?? []).map { ReadingPassage(item: $0).words.count }
            #expect(counts == counts.sorted(), "\(id) should get gradually longer")
        }
    }

    @Test func simplePhrasesHaveThreeToFiveWords() {
        let content = InMemoryContentRepository()
        for item in content.exercise(id: "sentences.simple-phrases")?.items ?? [] {
            #expect((3...5).contains(ReadingPassage(item: item).words.count), "\(item.text ?? "")")
        }
    }

    @Test func paragraphsHaveThreeToFiveSentences() {
        let content = InMemoryContentRepository()
        for item in content.exercise(id: "sentences.paragraphs")?.items ?? [] {
            let sentences = ReadingPassage(item: item).words.filter { $0.text.hasSuffix(".") || $0.text.hasSuffix("!") || $0.text.hasSuffix("?") }
            #expect((3...5).contains(sentences.count), "\(item.text ?? "")")
        }
    }

    @Test func everyCombinedSentenceUsesAJoiningWord() {
        let content = InMemoryContentRepository()
        let joiners: Set<String> = ["and", "but", "or", "so"]
        for item in content.exercise(id: "sentences.combined-sentences")?.items ?? [] {
            let words = ReadingPassage(item: item).words.map(\.spoken)
            #expect(words.contains(where: joiners.contains), "\(item.text ?? "")")
        }
    }

    @Test func startsIdleWithNothingHighlighted() {
        let vm = makeViewModel()

        #expect(vm.phase == .idle)
        #expect(vm.positionText == "Sentence 1 of 5")
        #expect(vm.words.map(\.text) == ["Good", "night,", "Grandma"])
        #expect(vm.words.allSatisfy { vm.highlight(for: $0) == .none })
    }

    @Test func theResultShowsAsSoonAsTheLastWordIsHeard() async {
        let vm = makeViewModel()

        vm.didTapMicrophone()
        // The pretend reader says every word with no gap; nothing should wait on a timer.
        for _ in 0..<20 where vm.result == nil { try? await Task.sleep(for: .milliseconds(10)) }

        #expect(vm.result != nil)
    }

    @Test func aWrongLastWordStillFinishesRightAway() {
        var tracker = ReadingTracker(words: ["a", "red", "ball"])

        tracker.align(heard: "a red bell")

        #expect(tracker.isFinished)
        #expect(tracker.incorrect == [2])
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

        let grandma = try #require(vm.words.last)
        vm.didTapWord(grandma)

        #expect(vm.phase == .paused)
        #expect(vm.selectedWord?.spoken == "grandma")
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
        let vm = makeViewModel(exerciseId: "sentences.simple-phrases")

        for index in 0..<5 {
            vm.didTapMicrophone()
            await waitForPassage(vm)
            #expect(vm.result?.percent == 100)
            #expect(vm.continueTitle == (index < 4 ? "Next sentence" : "Back to home"))
            if index < 4 { vm.didTapContinue() }
        }
    }

    @Test func tryAgainResetsThePassage() async {
        let vm = makeViewModel(exerciseId: "sentences.simple-phrases")
        vm.didTapMicrophone()
        await waitForPassage(vm)
        vm.didTapContinue()
        vm.didTapMicrophone()
        await waitForPassage(vm)

        vm.didTapTryAgain()

        #expect(vm.phase == .idle)
        #expect(vm.result == nil)
        #expect(vm.positionText == "Sentence 2 of 5")
        #expect(vm.words.allSatisfy { vm.highlight(for: $0) == .none })
    }
}

@MainActor
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

    @Test func aWordSaidAgainAfterAMistakeIsCorrected() {
        let heard = ReadingAccuracy.words(in: "the little cot cat sleeps")
        #expect(ReadingAccuracy.correctWords(expected: expected, heard: heard) == 4)
    }

    @Test func aWrongFirstWordLowersAccuracy() {
        let heard = ReadingAccuracy.words(in: "a little cat sleeps")
        #expect(ReadingAccuracy.correctWords(expected: expected, heard: heard) == 3)
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
        #expect(ReadingAccuracy.correctWords(expected: expected, heard: [String]()) == 0)
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

@MainActor
struct HeardWordTests {
    @Test func anAlternativeSpellingCountsAsHeard() {
        let heard = [HeardWord(options: ["how"]), HeardWord(options: ["i"]),
                     HeardWord(options: ["wander", "wonder"])]
        #expect(ReadingAccuracy.correctWords(expected: ["how", "i", "wonder"], heard: heard) == 3)
    }

    @Test func theTrackerFollowsAlternativesToo() {
        var tracker = ReadingTracker(words: ["how", "i", "wonder"])

        tracker.align(heard: [HeardWord(options: ["how"]), HeardWord(options: ["i"]),
                               HeardWord(options: ["wander", "wonder"])])

        #expect(tracker.isFinished)
    }
}

// MARK: - Edge cases

/// A reader the test drives step by step: what the recogniser "hears", when the child
/// goes quiet, and how listening ends.
@MainActor
final class ScriptedReadAloudService: ReadAloudService {
    var allowsMicrophone = true
    var startFailure: ReadAloudFailure?
    private(set) var isListening = false
    private(set) var startCount = 0
    private(set) var finishCount = 0
    private(set) var lastExpected = ""
    private var onHeard: (([HeardWord]) -> Void)?
    private var onQuiet: ((ReadAloudQuiet) -> Void)?
    private var onStopped: ((ReadAloudStop) -> Void)?

    func requestPermission() async -> Bool { allowsMicrophone }

    func start(
        expecting text: String,
        onHeard: @escaping ([HeardWord]) -> Void,
        onQuiet: @escaping (ReadAloudQuiet) -> Void,
        onStopped: @escaping (ReadAloudStop) -> Void
    ) -> ReadAloudFailure? {
        startCount += 1
        lastExpected = text
        if let startFailure { return startFailure }
        self.onHeard = onHeard
        self.onQuiet = onQuiet
        self.onStopped = onStopped
        isListening = true
        return nil
    }

    func finish() { finishCount += 1 }

    func stop() {
        onHeard = nil
        onQuiet = nil
        onStopped = nil
        isListening = false
    }

    /// Everything heard in this session so far, as the recogniser sends it.
    func hear(_ text: String) { onHeard?(HeardWord.words(in: text)) }
    func hear(_ words: [HeardWord]) { onHeard?(words) }
    func goQuiet(_ quiet: ReadAloudQuiet) { onQuiet?(quiet) }
    func end(_ reason: ReadAloudStop) {
        let stopped = onStopped
        stop()
        stopped?(reason)
    }
}

@MainActor
struct SentencesEdgeCaseTests {
    /// Short sentences, first passage: "I am hungry."
    private func makeViewModel(
        _ reader: ScriptedReadAloudService,
        exerciseId: String = "sentences.short-sentences"
    ) -> SentencesPracticeViewModel {
        let content = InMemoryContentRepository()
        return SentencesPracticeViewModel(
            exerciseId: exerciseId,
            content: content,
            reader: reader,
            voice: DummySpeechSynthesisService(),
            progress: InMemoryProgressRepository(content: content),
            router: AppRouter(isOnboardingComplete: true)
        )
    }

    /// Taps the mic and waits until it is listening (permission is asked first).
    private func startReading(_ vm: SentencesPracticeViewModel) async {
        vm.didTapMicrophone()
        for _ in 0..<100 where vm.phase != .reading && vm.phase != .micDenied {
            if case .micFailed = vm.phase { return }
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    private func highlight(_ vm: SentencesPracticeViewModel, _ index: Int) -> WordHighlight {
        vm.highlight(for: vm.words[index])
    }

    // Finishing

    @Test func readingEveryWordFinishesImmediately() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("I am hungry")

        #expect(vm.result?.percent == 100)
        #expect(reader.finishCount == 0)    // nothing to wait for
    }

    @Test func aWrongLastWordWaitsForThePauseNotForever() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("I am angry")
        #expect(vm.phase == .reading)                   // not finished early
        #expect(highlight(vm, 2) == .incorrect)

        reader.goQuiet(.pause)                          // the child stopped
        #expect(reader.finishCount == 1)                // final words asked for now
        reader.end(.recognizerEnded)

        #expect(vm.result?.correctWords == 2)
        #expect(vm.result?.totalWords == 3)
    }

    @Test func aWrongLastWordRevisedByTheFinalResultCountsAsRight() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("I am angry")
        reader.goQuiet(.pause)
        reader.hear("I am hungry")                      // the final result

        #expect(vm.result?.percent == 100)
    }

    @Test func aHalfHeardLastWordStaysCurrentInsteadOfRed() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("I am hun")

        #expect(highlight(vm, 2) == .current)
        #expect(vm.phase == .reading)

        reader.hear("I am hungry")
        #expect(vm.result?.percent == 100)
    }

    @Test func aHalfHeardLastWordIsScoredWrongIfThatIsAllThatWasSaid() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("I am hun")
        reader.goQuiet(.pause)
        #expect(reader.finishCount == 1)
        reader.end(.recognizerEnded)

        #expect(vm.result?.correctWords == 2)
    }

    @Test func aPauseBeforeTheLastWordDoesNotEndThePassage() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("I am")
        reader.goQuiet(.pause)

        #expect(reader.finishCount == 0)
        #expect(vm.phase == .reading)
        reader.hear("I am hungry")
        #expect(vm.result?.percent == 100)
    }

    @Test func aLongSilenceOnTheLastWordEndsThePassage() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("I am")
        reader.goQuiet(.long)
        #expect(reader.finishCount == 1)
        reader.end(.recognizerEnded)

        #expect(vm.result?.correctWords == 2)
    }

    @Test func aLongSilenceEarlyInAParagraphKeepsListening() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader, exerciseId: "sentences.paragraphs")
        await startReading(vm)

        reader.hear("Every morning I")
        reader.goQuiet(.long)

        #expect(reader.finishCount == 0)
        #expect(vm.phase == .reading)
    }

    @Test func noFinalResultStillFinishesWithWhatWasHeard() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("I am angry")
        reader.goQuiet(.pause)
        reader.end(.failed)                             // recogniser failed after finishing

        #expect(vm.result?.correctWords == 2)
    }

    // Wrong, skipped, repeated and extra words

    @Test func aWrongFirstWordTurnsRedAndReadingGoesOn() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("Hi")
        #expect(highlight(vm, 0) == .incorrect)
        #expect(highlight(vm, 1) == .current)

        reader.hear("Hi am hungry")
        #expect(vm.result?.correctWords == 2)
    }

    @Test func aSkippedWordTurnsRed() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("I hungry")

        #expect(vm.result?.correctWords == 2)
    }

    @Test func repeatedWordsAreNotCountedTwice() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("I I am am hungry")

        #expect(vm.result?.correctWords == 3)
        #expect(vm.result?.totalWords == 3)
    }

    @Test func extraWordsDoNotShiftTheRest() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("um I am really hungry")

        #expect(vm.result?.percent == 100)
    }

    @Test func aSelfCorrectionTurnsTheWordGreen() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader, exerciseId: "sentences.paragraphs")
        await startReading(vm)

        reader.hear("Every morning I wake up early I brush my teef")
        reader.hear("Every morning I wake up early I brush my teef teeth")

        let teeth = vm.words.firstIndex { $0.spoken == "teeth" }!
        #expect(highlight(vm, teeth) == .read)
    }

    // Pronunciation and spelling

    @Test func shortFormsAndSpellingsCount() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear("I'm hungry")

        #expect(vm.result?.percent == 100)
    }

    @Test func theRecognisersAlternativesCount() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.hear([HeardWord(options: ["i"]), HeardWord(options: ["am"]), HeardWord(options: ["angry", "hungry"])])

        #expect(vm.result?.percent == 100)
    }

    // Pauses, resuming and partial results

    @Test func pausingAndResumingKeepsProgress() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)
        reader.hear("I am")

        vm.didTapMicrophone()
        #expect(vm.phase == .paused)
        #expect(!reader.isListening)
        #expect(highlight(vm, 0) == .read)

        await startReading(vm)
        #expect(reader.lastExpected == "hungry.")
        reader.hear("hungry")
        #expect(vm.result?.percent == 100)
    }

    @Test func startingTheSentenceAgainAfterResumingIsNotCountedTwice() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)
        reader.hear("I am")
        vm.didTapMicrophone()
        await startReading(vm)

        reader.hear("I am hungry")

        #expect(vm.result?.correctWords == 3)
    }

    @Test func aRecogniserChangingItsMindDoesNotMoveBack() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader, exerciseId: "sentences.paragraphs")
        await startReading(vm)

        reader.hear("Every morning I wake")
        reader.hear("Every morning")

        #expect(vm.readCount == 4)
        #expect(highlight(vm, 3) == .read)
    }

    @Test func theRecogniserStoppingMidParagraphKeepsListening() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader, exerciseId: "sentences.paragraphs")
        await startReading(vm)

        reader.hear("Every morning")
        reader.end(.recognizerEnded)

        #expect(vm.phase == .reading)
        #expect(reader.startCount == 2)
        #expect(reader.lastExpected.hasPrefix("I wake up early."))
    }

    // Silence, permissions, failures and interruptions

    @Test func silenceShowsNoSpeechAndNoScore() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.end(.recognizerEnded)

        #expect(vm.phase == .noSpeech)
        #expect(vm.result == nil)
    }

    @Test func goingQuietWithoutAnyWordsDoesNothing() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)

        reader.goQuiet(.pause)
        reader.goQuiet(.long)

        #expect(reader.finishCount == 0)
        #expect(vm.phase == .reading)
    }

    @Test func refusedPermissionShowsTheRecoveryState() async {
        let reader = ScriptedReadAloudService()
        reader.allowsMicrophone = false
        let vm = makeViewModel(reader)

        vm.didTapMicrophone()
        for _ in 0..<100 where vm.phase == .idle { try? await Task.sleep(for: .milliseconds(5)) }

        #expect(vm.phase == .micDenied)
        #expect(reader.startCount == 0)
    }

    @Test func aMicrophoneThatWontStartSaysWhy() async {
        let reader = ScriptedReadAloudService()
        reader.startFailure = .noMicrophone
        let vm = makeViewModel(reader)

        await startReading(vm)

        #expect(vm.phase == .micFailed(.noMicrophone))
    }

    @Test func aRecognitionFailureKeepsProgressAndCanCarryOn() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)
        reader.hear("I am")

        reader.end(.failed)
        #expect(vm.phase == .recognitionFailed)
        #expect(vm.result == nil)

        await startReading(vm)
        reader.hear("hungry")
        #expect(vm.result?.percent == 100)
    }

    @Test func anInterruptionKeepsProgress() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)
        reader.hear("I am")

        reader.end(.interrupted)
        #expect(vm.phase == .interrupted)
        #expect(highlight(vm, 1) == .read)

        await startReading(vm)
        reader.hear("hungry")
        #expect(vm.result?.percent == 100)
    }

    @Test func anInterruptionWhileFinishingDoesNotScore() async {
        let reader = ScriptedReadAloudService()
        let vm = makeViewModel(reader)
        await startReading(vm)
        reader.hear("I am angry")
        reader.goQuiet(.pause)

        reader.end(.interrupted)

        #expect(vm.phase == .interrupted)
        #expect(vm.result == nil)
    }
}

@MainActor
struct SpokenWordMatcherTests {
    @Test func spellingDifferencesMatch() {
        #expect(SpokenWordMatcher.matches(HeardWord(options: ["favorite"]), "favourite"))
        #expect(SpokenWordMatcher.matches(HeardWord(options: ["mom"]), "mum"))
    }

    @Test func soundAlikesMatch() {
        #expect(SpokenWordMatcher.matches(HeardWord(options: ["where"]), "wear"))
        #expect(SpokenWordMatcher.matches(HeardWord(options: ["two"]), "too"))
    }

    @Test func differentWordsDoNotMatch() {
        #expect(!SpokenWordMatcher.matches(HeardWord(options: ["tooth"]), "teeth"))
        #expect(!SpokenWordMatcher.matches(HeardWord(options: ["cats"]), "cat"))
    }

    @Test func joinedAndSplitWordsMatch() {
        #expect(SpokenWordMatcher.joinedWord(HeardWord(options: ["teddybear"]), matches: "teddy", "bear"))
        #expect(SpokenWordMatcher.joinedWord(HeardWord(options: ["i'm"]), matches: "i", "am"))
        #expect(SpokenWordMatcher.splitWords(HeardWord(options: ["break"]), HeardWord(options: ["fast"]), match: "breakfast"))
    }

    @Test func theStartOfAWordIsRecognised() {
        #expect(SpokenWordMatcher.mayBeStartOf(HeardWord(options: ["hun"]), "hungry"))
        #expect(!SpokenWordMatcher.mayBeStartOf(HeardWord(options: ["angry"]), "hungry"))
    }
}

@MainActor
struct ReadingTrackerVariationTests {
    @Test func compoundAndSpellingVariationsAllCount() {
        var tracker = ReadingTracker(words: ["my", "favourite", "teddy", "bear"])

        tracker.align(heard: "my favorite teddybear")

        #expect(tracker.isFinished)
        #expect(tracker.correctCount == 4)
    }

    @Test func aWordSplitInTwoCountsOnce() {
        var tracker = ReadingTracker(words: ["eat", "my", "breakfast"])

        tracker.align(heard: "eat my break fast")

        #expect(tracker.isFinished)
        #expect(tracker.correctCount == 3)
    }

    @Test func aHalfHeardWordIsPendingUntilSettled() {
        let words = ["i", "am", "hungry"]
        let live = ReadingTracker.alignment(words, heard: HeardWord.words(in: "i am hun"), settled: false)
        let done = ReadingTracker.alignment(words, heard: HeardWord.words(in: "i am hun"), settled: true)

        #expect(live.position == 2 && live.isHearingCurrentWord)
        #expect(done.position == 3 && !done.matched.contains(2))
    }

    @Test func aWrongLastWordIsNotPending() {
        let live = ReadingTracker.alignment(["a", "red", "ball"], heard: HeardWord.words(in: "a red bell"), settled: false)

        #expect(live.position == 3)
        #expect(!live.isHearingCurrentWord)
    }
}
