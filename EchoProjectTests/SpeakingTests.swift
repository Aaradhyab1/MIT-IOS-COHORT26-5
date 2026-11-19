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

    @Test func exactWordIsCorrectEvenWithExtraWords() {
        #expect(PronunciationScorer.judge(heard: "Sun", accepted: ["sun"]) == .correct)
        #expect(PronunciationScorer.judge(heard: "it's a sun", accepted: ["sun"]) == .correct)
    }

    @Test func nearMissIsClose() {
        #expect(PronunciationScorer.judge(heard: "bowl", accepted: ["ball"]) == .close)
    }

    @Test func differentOrEmptyWordIsIncorrect() {
        #expect(PronunciationScorer.judge(heard: "elephant", accepted: ["up"]) == .incorrect)
        #expect(PronunciationScorer.judge(heard: "", accepted: ["up"]) == .incorrect)
    }

    // MARK: - Words model

    @Test func wordItemReadsChipsHintAndSpokenSounds() {
        let item = WordPracticeItem(ExerciseItem(
            id: "word-sun", text: "Sun",
            options: [Option(id: "0", label: "S"), Option(id: "1", label: "U"), Option(id: "2", label: "N")],
            hint: "sss · uh · nnn → sun", acceptedAnswers: ["sun", "son"]
        ))
        #expect(item.word == "Sun")
        #expect(item.soundChips == ["S", "U", "N"])
        #expect(item.spokenSounds == ["sss", "uh", "nnn"])
        #expect(item.acceptedAnswers == ["sun", "son"])
    }

    @Test func wordItemWithoutHintSpeaksTheChips() {
        let item = WordPracticeItem(ExerciseItem(id: "word-up", text: "Up",
                                                 options: [Option(id: "0", label: "U"), Option(id: "1", label: "P")]))
        #expect(item.spokenSounds == ["u", "p"])
        #expect(item.acceptedAnswers == ["Up"])
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
        #expect(sections.flatMap(\.rows).map(\.title) == ["2 letter", "3 letter", "4 letter", "5 letter & more"])
    }

    @Test func backDuringPracticeOpensTheSharedLeaveOverlay() async {
        let container = AppContainer.dummy(startPastOnboarding: true)
        let vm = container.makeWordsPracticeViewModel(exerciseId: "words.three-letter")
        await vm.onAppear()
        vm.didTapBack()
        #expect(container.router.overlay == .leavePractice)
    }

    @Test func wordsStartsListeningOnceTheSpeechModelIsReady() async {
        let container = AppContainer.dummy(startPastOnboarding: true)
        let vm = container.makeWordsPracticeViewModel(exerciseId: "words.three-letter")
        #expect(vm.phase == .preparing)
        await vm.onAppear()
        #expect(vm.phase == .listen)
        #expect(vm.word == "Sun")
        #expect(vm.soundChips == ["S", "U", "N"])
    }

    @Test func wordsShowsUnavailableWhenSpeechCannotRun() async {
        let speech = DummySpeechRecognitionService()
        speech.isAvailable = false
        let content = InMemoryContentRepository()
        let vm = WordsPracticeViewModel(
            exerciseId: "words.three-letter",
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

    @Test func parentCanMarkAWordCorrect() async {
        let container = AppContainer.dummy(startPastOnboarding: true)
        let vm = container.makeWordsPracticeViewModel(exerciseId: "words.three-letter")
        await vm.onAppear()
        vm.didTapMarkCorrect()
        #expect(vm.phase == .result(.correct))
    }
}
