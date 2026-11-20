import Foundation
import Testing
@testable import EchoProject

@MainActor
struct SplashViewModelTests {
    @Test func tappingSkipsToTheEnd() {
        let vm = SplashViewModel(router: AppRouter(isOnboardingComplete: false))

        vm.didTapScreen()

        #expect(vm.phase == .done)
    }

    @Test func handOffOpensAboutYourChildOnlyOnce() {
        let router = AppRouter(isOnboardingComplete: false)
        let vm = SplashViewModel(router: router)

        vm.finishHandOff()
        vm.finishHandOff()

        #expect(router.onboardingPath.count == 1)
    }
}

@MainActor
struct ChildProfileViewModelTests {
    /// Fixed "today": 19 Nov 2026.
    private let today = Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 19))!

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func makeViewModel(profile: InMemoryProfileRepository = InMemoryProfileRepository()) -> ChildProfileViewModel {
        ChildProfileViewModel(router: AppRouter(isOnboardingComplete: false), profile: profile, today: { today })
    }

    @Test func emptyFieldsHaveNoText() {
        let vm = makeViewModel()

        #expect(vm.text(for: .dateOfBirth) == nil)
        #expect(vm.text(for: .activationDate) == nil)
    }

    @Test func aConfirmedDateIsShownAsMonthDayYear() {
        let vm = makeViewModel()

        vm.didTapField(.dateOfBirth)
        vm.draftDate = date(2021, 3, 7)
        vm.didConfirmDate()

        #expect(vm.text(for: .dateOfBirth) == "03/07/2021")
        #expect(vm.editingField == nil)
    }

    @Test func continueSavesTheDatesWithoutAName() {
        let profile = InMemoryProfileRepository()
        let vm = makeViewModel(profile: profile)

        vm.didTapField(.activationDate)
        vm.draftDate = date(2024, 1, 15)
        vm.didConfirmDate()
        vm.didTapContinue()

        #expect(profile.currentProfile()?.activationDate == date(2024, 1, 15))
        #expect(profile.currentProfile()?.dateOfBirth == nil)
        #expect(profile.currentProfile()?.name == nil)
    }

    @Test func skipSavesNothing() {
        let profile = InMemoryProfileRepository()
        let vm = makeViewModel(profile: profile)

        vm.didTapField(.dateOfBirth)
        vm.draftDate = date(2021, 3, 7)
        vm.didConfirmDate()
        vm.didTapSkip()

        #expect(profile.currentProfile() == nil)
    }

    @Test func activationCannotBeBeforeBirth() {
        let vm = makeViewModel()
        vm.didTapField(.dateOfBirth)
        vm.draftDate = date(2021, 3, 7)
        vm.didConfirmDate()

        vm.didTapField(.activationDate)

        #expect(vm.draftRange.lowerBound == date(2021, 3, 7))
        #expect(vm.draftRange.upperBound == today)
    }

    @Test func aLaterBirthDateClearsAnEarlierActivationDate() {
        let vm = makeViewModel()
        vm.didTapField(.activationDate)
        vm.draftDate = date(2022, 5, 1)
        vm.didConfirmDate()

        vm.didTapField(.dateOfBirth)
        vm.draftDate = date(2023, 1, 1)
        vm.didConfirmDate()

        #expect(vm.text(for: .activationDate) == nil)
    }
}

@MainActor
struct ChoosePathViewModelTests {
    private func makeViewModel(
        router: AppRouter = AppRouter(isOnboardingComplete: false),
        profile: InMemoryProfileRepository = InMemoryProfileRepository()
    ) -> ChoosePathViewModel {
        ChoosePathViewModel(router: router, content: InMemoryContentRepository(), profile: profile)
    }

    @Test func showsTheFourListeningLevelsInOrder() {
        let vm = makeViewModel()

        #expect(vm.levels.map(\.number) == [1, 2, 3, 4])
        #expect(vm.levels.map(\.title) == ["Detection", "Differentiation", "Identification", "Comprehension"])
        #expect(vm.levels[1].summary == "Tell two sounds apart")
    }

    @Test func continueAppearsOnlyAfterPickingALevel() {
        let vm = makeViewModel()
        vm.didTapChooseLevel()
        #expect(vm.overlay == .customLevel)
        #expect(!vm.canContinue)

        vm.didTapLevelField()
        #expect(vm.isLevelListOpen)

        vm.didSelectLevel(vm.levels[2])
        #expect(!vm.isLevelListOpen)
        #expect(vm.selectedLevel?.title == "Identification")
        #expect(vm.canContinue)
    }

    @Test func continuingSavesTheLevelAndOpensHome() {
        let router = AppRouter(isOnboardingComplete: false)
        let profile = InMemoryProfileRepository()
        let vm = makeViewModel(router: router, profile: profile)

        vm.didTapChooseLevel()
        vm.didSelectLevel(vm.levels[3])
        vm.didTapContinue()

        #expect(profile.currentProfile()?.recommendedLevel == 4)
        #expect(profile.currentProfile()?.onboardingCompleted == true)
        #expect(router.isOnboardingComplete)
        #expect(vm.overlay == nil)
    }

    @Test func closingTheOverlayKeepsOnboardingGoing() {
        let router = AppRouter(isOnboardingComplete: false)
        let vm = makeViewModel(router: router)

        vm.didTapLevelInfo()
        vm.didDismissOverlay()

        #expect(vm.overlay == nil)
        #expect(!router.isOnboardingComplete)
    }

    @Test func quickCheckOpensTheQuestions() {
        let router = AppRouter(isOnboardingComplete: false)
        let vm = makeViewModel(router: router)

        vm.didTapQuickCheck()

        #expect(router.onboardingPath.count == 1)
    }
}

@MainActor
struct QuickCheckViewModelTests {
    private func makeViewModel(
        router: AppRouter = AppRouter(isOnboardingComplete: false),
        profile: InMemoryProfileRepository = InMemoryProfileRepository()
    ) -> QuickCheckViewModel {
        QuickCheckViewModel(router: router, content: InMemoryContentRepository(), profile: profile, advanceDelay: .zero)
    }

    @Test func startsOnQuestionOneOfEight() {
        let vm = makeViewModel()

        #expect(vm.questions.count == 8)
        #expect(vm.questionNumberText == "Question 1 of 8")
        #expect(vm.currentAnswer == nil)
    }

    @Test func choosingAnAnswerRecordsIt() {
        let vm = makeViewModel()

        vm.currentAnswer = .sometimes

        #expect(vm.answers["qc-1"] == .sometimes)
        #expect(vm.currentAnswer == .sometimes)
    }

    @Test func backGoesToThePreviousQuestionThenLeaves() {
        let router = AppRouter(isOnboardingComplete: false)
        router.go(.choosePath)
        router.go(.quickCheck)
        let vm = makeViewModel(router: router)
        vm.goToNextQuestion()

        vm.didTapBack()
        #expect(vm.currentIndex == 0)

        vm.didTapBack()
        #expect(router.onboardingPath.count == 1)
    }

    @Test func questionSixHasTheLingSoundChips() {
        let vm = makeViewModel()
        for _ in 0..<5 { vm.goToNextQuestion() }

        #expect(vm.currentQuestion?.choices == ["M", "AH", "OO", "E", "SH", "S"])
        vm.didToggleChoice("SH")
        #expect(vm.isChoiceSelected("SH"))
    }

    @Test func afterTheLastQuestionTheResultIsSavedAndShown() {
        let router = AppRouter(isOnboardingComplete: false)
        let profile = InMemoryProfileRepository()
        let vm = makeViewModel(router: router, profile: profile)

        for _ in vm.questions {
            vm.didSelect(.often)
            vm.goToNextQuestion()
        }

        #expect(profile.quickCheckResult()?.answers.count == 8)
        #expect(profile.quickCheckResult()?.recommendedLevel == 3)
        #expect(router.onboardingPath.count == 1)
    }
}

@MainActor
struct QuickCheckResultViewModelTests {
    private func makeViewModel(router: AppRouter = AppRouter(isOnboardingComplete: false),
                               profile: InMemoryProfileRepository) -> QuickCheckResultViewModel {
        QuickCheckResultViewModel(router: router, content: InMemoryContentRepository(), profile: profile, stepDelay: .zero)
    }

    @Test func recommendsTheQuickCheckLevel() {
        let profile = InMemoryProfileRepository(result: QuickCheckResult(answers: [:], recommendedLevel: 3))
        let vm = makeViewModel(profile: profile)

        #expect(vm.recommendation?.heading == "Level 3 \u{00B7} Identification")
        #expect(vm.recommendation?.blurb == "Name everyday sounds, animals and voices.")
        #expect(vm.revealedStep == 1)
        #expect(!vm.isContinueVisible)
    }

    @Test func revealCountsUpToTheLevelThenShowsContinue() async {
        let profile = InMemoryProfileRepository(result: QuickCheckResult(answers: [:], recommendedLevel: 3))
        let vm = makeViewModel(profile: profile)

        await vm.didAppear(reduceMotion: false)

        #expect(vm.revealedStep == 3)
        #expect(vm.isContinueVisible)
    }

    @Test func continueSavesTheLevelAndOpensHome() {
        let router = AppRouter(isOnboardingComplete: false)
        let profile = InMemoryProfileRepository(result: QuickCheckResult(answers: [:], recommendedLevel: 3))
        let vm = makeViewModel(router: router, profile: profile)

        vm.didTapContinue()

        #expect(profile.currentProfile()?.recommendedLevel == 3)
        #expect(profile.currentProfile()?.onboardingCompleted == true)
        #expect(router.isOnboardingComplete)
    }
}
