import Testing
@testable import EchoProject

/// Words: pronunciation scoring and the ViewModels, on dummy services.
@MainActor
struct SpeakingTests {

    // MARK: - PronunciationScorer

    @Test func cleansPunctuationCaseAndDigits() {
        #expect(PronunciationScorer.words(in: "Up, 2 Dogs!") == ["up", "two", "dogs"])
    }

    @Test func editDistanceCountsSingleLetterChanges() {
        #expect(PronunciationScorer.editDistance("sun", "son") == 1)
        #expect(PronunciationScorer.editDistance("ball", "ball") == 0)
        #expect(PronunciationScorer.editDistance("", "cat") == 3)
    }

    @Test func justTheWordIsCorrect() {
        #expect(PronunciationScorer.judge(heard: "Sun", accepted: ["sun"]) == .correct)
        #expect(PronunciationScorer.judge(heard: "Sun.", accepted: ["sun"]) == .correct)
    }

    @Test func sentenceContainingTheWordIsIncorrect() {
        #expect(PronunciationScorer.judge(heard: "it's a sun", accepted: ["sun"]) == .incorrect)
        #expect(PronunciationScorer.judge(heard: "sun sun", accepted: ["sun"]) == .incorrect)
        #expect(PronunciationScorer.judge(heard: "I like the sun", accepted: ["sun", "son"]) == .incorrect)
    }

    @Test func nearMissIsClose() {
        #expect(PronunciationScorer.judge(heard: "bowl", accepted: ["ball"]) == .close)
    }

    @Test func differentOrEmptyWordIsIncorrect() {
        #expect(PronunciationScorer.judge(heard: "elephant", accepted: ["up"]) == .incorrect)
        #expect(PronunciationScorer.judge(heard: "", accepted: ["up"]) == .incorrect)
    }

    // MARK: - Words model

    @Test func wordItemReadsPartsHintAndAnswers() {
        let item = WordPracticeItem(ExerciseItem(
            id: "word-sun", text: "Sun",
            options: [Option(id: "0", label: "S", pronunciation: "suh"),
                      Option(id: "1", label: "UN", pronunciation: "un")],
            hint: "s · un → sun", acceptedAnswers: ["sun", "son"]
        ))
        #expect(item.word == "Sun")
        #expect(item.soundChips == ["S", "UN"])
        #expect(item.parts == [WordPart(chip: "S", sound: "suh"), WordPart(chip: "UN", sound: "un")])
        #expect(item.acceptedAnswers == ["sun", "son"])
    }

    @Test func everyWordIsBrokenIntoPartsWithSounds() {
        let content = InMemoryContentRepository()
        for id in ["words.one-syllable", "words.two-syllable", "words.three-syllable", "words.four-plus-syllable"] {
            for item in content.exercise(id: id)?.items ?? [] {
                let word = WordPracticeItem(item)
                #expect(!word.parts.isEmpty, "\(word.word) needs at least one part")
                #expect(word.parts.allSatisfy { $0.sound != nil }, "\(word.word) has a part without a sound")
                // The parts spell the word: "S" + "UN" = "SUN".
                #expect(word.soundChips.joined() == word.word.uppercased(), "\(word.word) parts don't spell it")
            }
        }
    }

    @Test func longerWordsAreSplitIntoOnePartPerSyllable() {
        let content = InMemoryContentRepository()
        let syllables = ["words.one-syllable": 1, "words.two-syllable": 2, "words.three-syllable": 3]
        for (id, count) in syllables {
            for item in content.exercise(id: id)?.items ?? [] {
                #expect(WordPracticeItem(item).parts.count == count, "\(item.text ?? "") should have \(count) parts")
            }
        }
        for item in content.exercise(id: "words.four-plus-syllable")?.items ?? [] {
            #expect(WordPracticeItem(item).parts.count >= 4, "\(item.text ?? "") should have 4 or more parts")
        }
    }

    // MARK: - ViewModels

    @Test func wordsListShowsTheFourWordExercises() {
        let container = AppContainer.dummy(startPastOnboarding: true)
        let vm = container.makeLevelLibraryViewModel(levelId: "speaking.words")
        guard case .ready(let title, let sections) = vm.state else {
            Issue.record("Words library did not load")
            return
        }
        #expect(title == "Words")
        #expect(sections.flatMap(\.rows).map(\.title) == ["1 syllable", "2 syllables", "3 syllables", "4 syllables & more"])
    }

    @Test func backDuringPracticeOpensTheSharedLeaveOverlay() async {
        let container = AppContainer.dummy(startPastOnboarding: true)
        let vm = container.makeWordsPracticeViewModel(exerciseId: "words.two-syllable")
        await vm.onAppear()
        vm.didTapBack()
        #expect(container.router.overlay == .leavePractice)
    }

    @Test func wordsStartsListeningOnceTheSpeechModelIsReady() async {
        let container = AppContainer.dummy(startPastOnboarding: true)
        let vm = container.makeWordsPracticeViewModel(exerciseId: "words.two-syllable")
        #expect(vm.phase == .preparing)
        await vm.onAppear()
        #expect(vm.phase == .listen)
        #expect(!vm.word.isEmpty)
        #expect(!vm.soundChips.isEmpty)
    }

    @Test func eachWordExerciseHasTwelveWords() {
        let content = InMemoryContentRepository()
        for id in ["words.one-syllable", "words.two-syllable", "words.three-syllable", "words.four-plus-syllable"] {
            #expect(content.exercise(id: id)?.items.count == 12, "\(id) should have 12 words")
        }
    }

    @Test func practicePicksFiveRandomWordsFromTheExercise() {
        let container = AppContainer.dummy(startPastOnboarding: true)
        let allWords = Set(container.content.exercise(id: "words.two-syllable")?.items.compactMap(\.text) ?? [])
        let vm = container.makeWordsPracticeViewModel(exerciseId: "words.two-syllable")
        #expect(vm.wordCount == WordsPracticeViewModel.wordsPerSession)
        #expect(allWords.contains(vm.word))
    }

    @Test func wordsShowsUnavailableWhenSpeechCannotRun() async {
        let speech = DummySpeechRecognitionService()
        speech.isAvailable = false
        let content = InMemoryContentRepository()
        let vm = WordsPracticeViewModel(
            exerciseId: "words.two-syllable",
            content: content,
            recording: DummyRecordingService(),
            speech: speech,
            voice: DummySpeechSynthesisService(),
            progress: InMemoryProgressRepository(content: content),
            router: AppRouter(isOnboardingComplete: true)
        )
        await vm.onAppear()
        #expect(vm.phase == .unavailable)
    }

    @Test func recordStartsRecordingStraightAway() async throws {
        let container = AppContainer.dummy(startPastOnboarding: true)
        let vm = container.makeWordsPracticeViewModel(exerciseId: "words.two-syllable")
        await vm.onAppear()
        vm.didTapRecord()
        try await Task.sleep(for: .milliseconds(100))   // permission checks run first
        #expect(vm.phase == .recording)
        vm.stopAll()
    }
}
