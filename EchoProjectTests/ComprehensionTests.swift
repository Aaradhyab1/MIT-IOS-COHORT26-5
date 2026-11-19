import Foundation
import Testing
@testable import EchoProject

@MainActor
struct ComprehensionTests {
    private let storyId = "comprehension.story.cat-and-bird"

    private func makeStory(router: AppRouter, narrator: MockStoryNarrationService? = nil) -> StoryPlayerViewModel {
        let content = InMemoryContentRepository()
        return StoryPlayerViewModel(
            exerciseId: storyId,
            content: content,
            narrator: narrator ?? MockStoryNarrationService(simulatesPlayback: false),
            progress: InMemoryProgressRepository(content: content, sessions: [], progress: []),
            router: router
        )
    }

    /// A story on its first page, with the narrator the test controls.
    private func makeStoryPage() -> (StoryPlayerViewModel, MockStoryNarrationService) {
        let narrator = MockStoryNarrationService(simulatesPlayback: false)
        let vm = makeStory(router: AppRouter(isOnboardingComplete: true), narrator: narrator)
        vm.didTapBegin()
        return (vm, narrator)
    }

    private func orderingItem() -> ExerciseItem {
        ExerciseItem(
            id: "test.ordering",
            prompt: "Put the events in order",
            text: "Drag each card into the right number.",
            options: [Option(id: "a", label: "A"), Option(id: "b", label: "B"), Option(id: "c", label: "C")]
        )
    }

    private func matchingItems() -> (ExerciseItem, ExerciseItem) {
        let question = ExerciseItem(id: "test.matching", prompt: "Who did what?",
                                    options: [Option(id: "bird", label: "Bird"), Option(id: "cat", label: "Cat")])
        let answers = ExerciseItem(id: "test.matching-answers",
                                   options: [Option(id: "bird", label: "Ate"), Option(id: "cat", label: "Chased")])
        return (question, answers)
    }

    // MARK: - Story

    @Test func storyStartsOnStoryTimeWithBothQuestions() {
        let vm = makeStory(router: AppRouter(isOnboardingComplete: true))

        #expect(vm.state == .intro)
        #expect(vm.ordering != nil)
        #expect(vm.matching != nil)

        vm.didTapBegin()
        #expect(vm.state == .listening(pageIndex: 0))
        #expect(vm.canGoNext == false)
    }

    @Test func questionsComeInOrderAndEndOnStoryComplete() {
        let router = AppRouter(isOnboardingComplete: true)
        let vm = makeStory(router: router)

        vm.didTapStartQuestions()
        #expect(vm.state == .ordering)
        #expect(vm.questionLabel == "Question 1 of 2")

        vm.ordering?.didTapContinue()
        #expect(vm.state == .matching)
        #expect(vm.questionLabel == "Question 2 of 2")

        vm.matching?.didTapContinue()
        #expect(vm.state == .complete(allCorrectFirstTime: false))
        #expect(router.listeningPath.count == 1)   // the shared completion screen
    }

    @Test func backOpensTheSharedLeaveOverlay() {
        let router = AppRouter(isOnboardingComplete: true)
        let vm = makeStory(router: router)

        vm.didTapBack()

        #expect(router.overlay == .leavePractice)
    }

    // MARK: - Narration

    @Test func playReadsThePageFromTheStart() {
        let (vm, narrator) = makeStoryPage()

        vm.didTapPlay()
        narrator.send(.started)

        #expect(narrator.calls == [.speak(from: 0, speed: .normal)])
        #expect(narrator.spokenText == vm.currentPage?.text)
        #expect(vm.playback == .playing)
    }

    @Test func playButtonPausesAndResumes() {
        let (vm, narrator) = makeStoryPage()
        vm.didTapPlay()
        narrator.send(.started)

        vm.didTapPlay()
        narrator.send(.paused)
        #expect(narrator.calls.last == .pause)
        #expect(vm.playback == .paused)

        vm.didTapPlay()
        narrator.send(.resumed)
        #expect(narrator.calls.last == .resume)
        #expect(vm.playback == .playing)
    }

    @Test func finishingUnlocksNextAndPlayListensAgain() {
        let (vm, narrator) = makeStoryPage()
        vm.didTapPlay()
        narrator.send(.started)
        narrator.send(.progress(0.6))
        #expect(vm.canGoNext == false)

        narrator.send(.finished)
        #expect(vm.playback == .finished)
        #expect(vm.playbackFraction == 1)
        #expect(vm.canGoNext)
        #expect(vm.elapsedText == vm.durationText)

        vm.didTapPlay()
        #expect(narrator.calls.last == .speak(from: 0, speed: .normal))
    }

    @Test func changingSpeedWhilePlayingCarriesOnFromTheSamePlace() {
        let (vm, narrator) = makeStoryPage()
        vm.didTapPlay()
        narrator.send(.started)
        narrator.send(.progress(0.5))

        vm.didSelectSpeed(.slow)

        #expect(vm.speed == .slow)
        #expect(narrator.calls.last == .speak(from: 0.5, speed: .slow))
    }

    @Test func slowerSpeedMakesTheStoryLonger() {
        let narrator = MockStoryNarrationService(simulatesPlayback: false)
        let text = "The bird saw the bread. The cat chased the bird. The bird flew away safely."

        let slow = narrator.estimatedDuration(of: text, speed: .slow)
        let fast = narrator.estimatedDuration(of: text, speed: .fast)

        #expect(slow > fast)
    }

    @Test func releasingTheSliderReadsFromThere() {
        let (vm, narrator) = makeStoryPage()

        vm.didDragSlider(to: 0.4)
        narrator.send(.progress(0.1))
        #expect(vm.playbackFraction == 0.4)

        vm.didReleaseSlider()
        #expect(narrator.calls.last == .speak(from: 0.4, speed: .normal))
    }

    @Test func aSoundErrorShowsAMessageAndStillLetsTheChildGoOn() {
        let (vm, narrator) = makeStoryPage()
        vm.didTapPlay()

        narrator.send(.failed("No sound"))

        #expect(vm.errorMessage == "No sound")
        #expect(vm.playback == .ready)
        #expect(vm.canGoNext)

        vm.dismissError()
        #expect(vm.errorMessage == nil)
    }

    @Test func leavingThePageStopsTheStory() {
        let (vm, narrator) = makeStoryPage()
        vm.didTapPlay()
        narrator.send(.started)

        vm.didLeaveStoryPage()

        #expect(narrator.calls.last == .stop)
        #expect(vm.playback == .ready)
    }

    @Test func nextStopsTheStoryAndMovesOn() {
        let (vm, narrator) = makeStoryPage()
        vm.didTapPlay()
        narrator.send(.finished)

        vm.didTapNext()

        #expect(narrator.calls.last == .stop)
        #expect(vm.state == .storyFinished)
    }

    @Test func storyIsSplitIntoSentencesWithTheirPositions() {
        let text = "The cat chased the bird! The bird flew away."

        let sentences = StoryText.sentences(in: text)

        #expect(sentences.count == 2)
        #expect(sentences[1].offset == 25)
        #expect(sentences[1].text.hasPrefix("The bird flew away."))
    }

    // MARK: - Ordering

    @Test func orderingStartsMixedUpWithEmptyPlaces() {
        let vm = OrderingViewModel(item: orderingItem()) { _ in }

        #expect(vm.slots.allSatisfy { $0.card == nil })
        #expect(vm.pool.map(\.id) == ["b", "a", "c"])
        #expect(vm.canCheck == false)
    }

    @Test func placingCardsInTheRightOrderIsCorrect() {
        var finishedFirstTime: Bool?
        let vm = OrderingViewModel(item: orderingItem()) { finishedFirstTime = $0 }

        for id in ["a", "b", "c"] {
            vm.didTapPoolCard(vm.pool.first { $0.id == id }!)
        }
        vm.didTapCheck()
        vm.didTapContinue()

        #expect(vm.state == .correct)
        #expect(finishedFirstTime == true)
    }

    @Test func aWrongOrderMarksSlotsAndTryAgainResets() {
        let vm = OrderingViewModel(item: orderingItem()) { _ in }

        for card in vm.pool { vm.didTapPoolCard(card) }
        vm.didTapCheck()

        #expect(vm.state == .incorrect)
        #expect(vm.mark(for: vm.slots[0]) == .incorrect)
        #expect(vm.mark(for: vm.slots[2]) == .correct)

        vm.didTapTryAgain()
        #expect(vm.state == .answering)
        #expect(vm.pool.count == 3)
    }

    @Test func tappingAPlacedCardSendsItBack() {
        let vm = OrderingViewModel(item: orderingItem()) { _ in }

        vm.didTapPoolCard(vm.pool[0])
        vm.didTapSlot(vm.slots[0])

        #expect(vm.slots[0].card == nil)
        #expect(vm.pool.count == 3)
    }

    // MARK: - Matching

    @Test func pairingEveryCharacterCorrectlyIsCorrect() {
        let (question, answers) = matchingItems()
        let vm = MatchingViewModel(question: question, answers: answers) { _ in }

        for row in vm.rows {
            vm.didTapLeft(row.left)
            vm.didTapRight(row.right)
        }
        #expect(vm.pairNumber(forRight: vm.rows[1].right) == 2)

        vm.didTapCheck()
        #expect(vm.state == .correct)
    }

    @Test func crossedPairsAreIncorrect() {
        let (question, answers) = matchingItems()
        let vm = MatchingViewModel(question: question, answers: answers) { _ in }

        vm.didTapLeft(vm.rows[0].left); vm.didTapRight(vm.rows[1].right)
        vm.didTapLeft(vm.rows[1].left); vm.didTapRight(vm.rows[0].right)
        vm.didTapCheck()

        #expect(vm.state == .incorrect)
        #expect(vm.mark(forLeft: vm.rows[0].left) == .incorrect)
    }

    @Test func anActionBelongsToOnlyOneCharacter() {
        let (question, answers) = matchingItems()
        let vm = MatchingViewModel(question: question, answers: answers) { _ in }

        vm.didTapLeft(vm.rows[0].left); vm.didTapRight(vm.rows[0].right)
        vm.didTapLeft(vm.rows[1].left); vm.didTapRight(vm.rows[0].right)

        #expect(vm.matches.count == 1)
        #expect(vm.pairNumber(forLeft: vm.rows[0].left) == nil)
    }
}
