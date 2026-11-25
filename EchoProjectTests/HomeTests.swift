import Foundation
import Testing
@testable import EchoProject

@MainActor
struct GreetingTests {
    private func at(_ hour: Int, _ minute: Int = 0) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 25, hour: hour, minute: minute))!
    }

    @Test func followsTheFigmaTimeRanges() {
        #expect(Greeting.text(for: at(5)) == "Good morning")
        #expect(Greeting.text(for: at(11, 59)) == "Good morning")
        #expect(Greeting.text(for: at(12)) == "Good afternoon")
        #expect(Greeting.text(for: at(16, 59)) == "Good afternoon")
        #expect(Greeting.text(for: at(17)) == "Good evening")
        #expect(Greeting.text(for: at(4, 59)) == "Good evening")
    }
}

@MainActor
struct ListeningHomeViewModelTests {
    private func makeViewModel(level: Int = 3, router: AppRouter = AppRouter(isOnboardingComplete: true)) -> ListeningHomeViewModel {
        let content = InMemoryContentRepository()
        return ListeningHomeViewModel(
            content: content,
            profile: InMemoryProfileRepository(profile: ChildProfile(recommendedLevel: level, onboardingCompleted: true)),
            progress: InMemoryProgressRepository(content: content),
            router: router
        )
    }

    @Test func todaysPracticeIsTheExerciseInProgress() {
        let vm = makeViewModel()

        #expect(vm.todaysPractice?.exerciseId == "identification.animals")
        #expect(vm.todaysPractice?.badgeText == "You're at Level 3")
        #expect(vm.todaysPractice?.countText == "10 sounds")
    }

    @Test func categoriesStartWithTodaysOne() {
        let vm = makeViewModel()

        #expect(vm.levelTitle == "Level 3 - Identify more sounds")
        #expect(vm.categories.map(\.title) == ["Animals", "Instruments", "Nature", "Objects"])
        #expect(vm.categories.first?.detailText == "4 of 10")
        #expect(vm.categories.last?.detailText == "New")
    }

    @Test func reviewShowsGamesFromEarlierLevels() {
        let vm = makeViewModel()

        #expect(vm.reviewSubtitle == "Replay games from Levels 1 and 2.")
        #expect(vm.reviewCards.allSatisfy { $0.levelNumber < 3 })
        #expect(vm.reviewCards.first?.title == "Story Hide & Seek")
    }

    @Test func levelOneHasNothingToReplay() {
        let vm = makeViewModel(level: 1)

        #expect(vm.reviewCards.isEmpty)
    }

    @Test func nextLevelIsLocked() {
        let vm = makeViewModel()

        #expect(vm.upNext?.eyebrow == "Up next \u{00B7} Level 4")
        #expect(vm.upNext?.title == "Understand sounds")
        #expect(vm.upNext?.detail == "Play 4 more games to unlock.")
    }

    @Test func startOpensBeforeYouStart() {
        let router = AppRouter(isOnboardingComplete: true)
        let vm = makeViewModel(router: router)

        vm.didTapStart()

        #expect(router.listeningPath.count == 1)
    }
}

@MainActor
struct SpeakingHomeViewModelTests {
    private func makeViewModel() -> SpeakingHomeViewModel {
        let content = InMemoryContentRepository()
        return SpeakingHomeViewModel(content: content, progress: InMemoryProgressRepository(content: content),
                                     router: AppRouter(isOnboardingComplete: true))
    }

    @Test func startsOnSkillOneSpeechSounds() {
        let vm = makeViewModel()

        #expect(vm.todaysPractice?.badgeText == "You're on Skill 1")
        #expect(vm.todaysPractice?.title == "Speech Sounds")
        #expect(vm.todaysPractice?.countText == "4 sounds")
    }

    @Test func listsTheThreeSkillsAndTheConversation() {
        let vm = makeViewModel()

        #expect(vm.skillCards.map(\.title) == ["Sounds", "Words", "Sentences"])
        #expect(vm.skillCards.first?.meta.hasPrefix("Skill 1 \u{00B7} ") == true)
        #expect(vm.conversation?.exerciseId == "conversation.ice-cream-shop")
    }
}
