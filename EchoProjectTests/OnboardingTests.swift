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
