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

    @Test func orderingHowToPlayCanBeOpenedAndDismissedWithoutChangingTheAnswer() {
        let vm = OrderingViewModel(item: orderingItem()) { _ in }
        let initialPool = vm.pool

        vm.didTapHowToPlay()
        #expect(vm.isShowingTutorial)
        #expect(vm.pool == initialPool)

        vm.didTapDismissTutorial()
        #expect(vm.isShowingTutorial == false)
        #expect(vm.state == .answering)
    }

    @Test func orderingTutorialCompletesImmediatelyWhenReduceMotionIsEnabled() async {
        let vm = OrderingViewModel(item: orderingItem()) { _ in }
        vm.didTapHowToPlay()

        await vm.playTutorial(reduceMotion: true)

        #expect(vm.tutorialIsComplete)
        #expect(vm.tutorialCard(forSlot: 0)?.id == "seed")
        #expect(vm.tutorialCard(forSlot: 1)?.id == "water")
        #expect(vm.tutorialCard(forSlot: 2)?.id == "flower")
        #expect(vm.tutorialPool.isEmpty)
    }

    @Test func skippingOrderingTutorialInvalidatesItsPlayback() async {
        let vm = OrderingViewModel(item: orderingItem()) { _ in }
        vm.didTapHowToPlay()
        let playbackID = vm.tutorialPlaybackID
        let playback = Task { await vm.playTutorial(reduceMotion: false) }

        playback.cancel()
        vm.didTapDismissTutorial()
        await playback.value

        #expect(vm.tutorialPlaybackID > playbackID)
        #expect(!vm.isShowingTutorial)
        #expect(vm.tutorialStep == .waiting)
    }

    // MARK: - Matching

    private typealias Endpoint = MatchingViewModel.Endpoint

    private func makeMatching() -> MatchingViewModel {
        let (question, answers) = matchingItems()
        return MatchingViewModel(question: question, answers: answers) { _ in }
    }

    /// Simulates a finger dragging a line from one card and lifting over another.
    private func drag(_ vm: MatchingViewModel, from origin: Endpoint, to target: Endpoint?) {
        vm.didBeginConnecting(from: origin)
        vm.didMoveConnection(over: target)
        vm.didEndConnecting()
    }

    @Test func draggingEveryCharacterToItsActionIsCorrect() {
        let vm = makeMatching()

        for row in vm.rows {
            drag(vm, from: Endpoint(side: .left, tileId: row.left.id), to: Endpoint(side: .right, tileId: row.right.id))
        }
        #expect(vm.connections.count == 2)
        #expect(vm.canCheck)

        vm.didTapCheck()
        #expect(vm.state == .correct)
        #expect(vm.connections.allSatisfy { vm.mark(for: $0) == .correct })
    }

    @Test func aLineCanBeDrawnFromEitherSide() {
        let vm = makeMatching()

        drag(vm, from: Endpoint(side: .right, tileId: "cat"), to: Endpoint(side: .left, tileId: "cat"))

        #expect(vm.matches == ["cat": "cat"])
    }

    @Test func crossedLinesAreIncorrectAndTryAgainClearsThem() {
        let vm = makeMatching()

        drag(vm, from: Endpoint(side: .left, tileId: "bird"), to: Endpoint(side: .right, tileId: "cat"))
        drag(vm, from: Endpoint(side: .left, tileId: "cat"), to: Endpoint(side: .right, tileId: "bird"))
        vm.didTapCheck()

        #expect(vm.state == .incorrect)
        #expect(vm.mark(for: Endpoint(side: .left, tileId: "bird")) == .incorrect)
        #expect(vm.mark(for: Endpoint(side: .right, tileId: "bird")) == .incorrect)

        vm.didTapTryAgain()
        #expect(vm.state == .answering)
        #expect(vm.connections.isEmpty)
    }

    @Test func noMarksAreShownBeforeChecking() {
        let vm = makeMatching()

        drag(vm, from: Endpoint(side: .left, tileId: "bird"), to: Endpoint(side: .right, tileId: "cat"))

        #expect(vm.mark(for: Endpoint(side: .left, tileId: "bird")) == nil)
    }

    @Test func anActionBelongsToOnlyOneCharacter() {
        let vm = makeMatching()

        drag(vm, from: Endpoint(side: .left, tileId: "bird"), to: Endpoint(side: .right, tileId: "bird"))
        drag(vm, from: Endpoint(side: .left, tileId: "cat"), to: Endpoint(side: .right, tileId: "bird"))

        #expect(vm.matches == ["cat": "bird"])
        #expect(!vm.isConnected(Endpoint(side: .left, tileId: "bird")))
    }

    @Test func draggingAConnectedCardMovesItsLine() {
        let vm = makeMatching()
        let bird = Endpoint(side: .left, tileId: "bird")
        drag(vm, from: bird, to: Endpoint(side: .right, tileId: "cat"))

        drag(vm, from: bird, to: Endpoint(side: .right, tileId: "bird"))

        #expect(vm.matches == ["bird": "bird"])
    }

    @Test func droppingAwayFromACardDrawsNoLine() {
        let vm = makeMatching()
        let bird = Endpoint(side: .left, tileId: "bird")

        drag(vm, from: bird, to: nil)
        #expect(vm.connections.isEmpty)

        drag(vm, from: bird, to: Endpoint(side: .right, tileId: "bird"))
        drag(vm, from: bird, to: nil)
        #expect(vm.connections.isEmpty)
        #expect(!vm.isConnecting)
    }

    @Test func aCardOnTheSameSideIsNeverATarget() {
        let vm = makeMatching()
        let bird = Endpoint(side: .left, tileId: "bird")

        vm.didBeginConnecting(from: bird)
        vm.didMoveConnection(over: Endpoint(side: .left, tileId: "cat"))
        #expect(vm.dragTarget == nil)
        vm.didEndConnecting()

        #expect(vm.connections.isEmpty)
    }

    @Test func theDragHighlightsTheOriginAndTarget() {
        let vm = makeMatching()
        let bird = Endpoint(side: .left, tileId: "bird")
        let action = Endpoint(side: .right, tileId: "cat")

        vm.didBeginConnecting(from: bird)
        vm.didMoveConnection(over: action)

        #expect(vm.isConnecting)
        #expect(vm.isHighlighted(bird))
        #expect(vm.isHighlighted(action))
        #expect(!vm.isHighlighted(Endpoint(side: .right, tileId: "bird")))
    }

    @Test func aCancelledDragConnectsNothing() {
        let vm = makeMatching()

        vm.didBeginConnecting(from: Endpoint(side: .left, tileId: "bird"))
        vm.didMoveConnection(over: Endpoint(side: .right, tileId: "bird"))
        vm.didCancelConnecting()

        #expect(vm.connections.isEmpty)
        #expect(!vm.isConnecting)
    }

    @Test func eachConnectionBumpsTheHapticRevision() {
        let vm = makeMatching()

        drag(vm, from: Endpoint(side: .left, tileId: "bird"), to: Endpoint(side: .right, tileId: "bird"))
        drag(vm, from: Endpoint(side: .left, tileId: "cat"), to: nil)

        #expect(vm.connectionRevision == 1)
    }

    @Test func linesCannotBeChangedAfterChecking() {
        let vm = makeMatching()
        for row in vm.rows {
            vm.connect(Endpoint(side: .left, tileId: row.left.id), Endpoint(side: .right, tileId: row.right.id))
        }
        vm.didTapCheck()

        drag(vm, from: Endpoint(side: .left, tileId: "bird"), to: Endpoint(side: .right, tileId: "cat"))
        vm.disconnect(Endpoint(side: .left, tileId: "cat"))

        #expect(vm.matches == ["bird": "bird", "cat": "cat"])
    }

    @Test func voiceOverCanConnectAndRemoveLines() {
        let vm = makeMatching()
        let bird = Endpoint(side: .left, tileId: "bird")

        #expect(vm.candidates(for: bird).map(\.tileId) == ["bird", "cat"])
        vm.connect(bird, Endpoint(side: .right, tileId: "cat"))
        #expect(vm.connectedTile(for: bird)?.label == "Chased")

        vm.disconnect(Endpoint(side: .right, tileId: "cat"))
        #expect(vm.connectedTile(for: bird) == nil)
    }

    @Test func matchingHowToPlayCanBeOpenedAndDismissedWithoutChangingThePairs() {
        let vm = makeMatching()
        vm.connect(Endpoint(side: .left, tileId: "bird"), Endpoint(side: .right, tileId: "bird"))

        vm.didTapHowToPlay()
        #expect(vm.isShowingTutorial)
        #expect(!vm.tutorialHasStarted)
        #expect(vm.tutorialCanSkip)

        vm.didTapDismissTutorial()
        #expect(vm.isShowingTutorial == false)
        #expect(vm.state == .answering)
        #expect(vm.matches == ["bird": "bird"])
    }

    @Test func noLineCanBeDrawnWhileTheTutorialIsShowing() {
        let vm = makeMatching()
        vm.didTapHowToPlay()

        drag(vm, from: Endpoint(side: .left, tileId: "bird"), to: Endpoint(side: .right, tileId: "bird"))

        #expect(vm.connections.isEmpty)
    }

    @Test func matchingTutorialConnectsAllThreePairsWhenReduceMotionIsEnabled() async {
        let vm = makeMatching()
        vm.didTapHowToPlay()

        await vm.playTutorial(reduceMotion: true)

        #expect(vm.tutorialIsComplete)
        #expect(vm.tutorialIsChecked)
        #expect(!vm.tutorialCanSkip)
        #expect(!vm.tutorialShowsHand)
        for pair in ComprehensionTutorial.matchingPairs.indices {
            #expect(vm.tutorialPairIsConnected(at: pair))
        }

        vm.didTapDismissTutorial()
        #expect(vm.isShowingTutorial == false)
        #expect(vm.matches.isEmpty)
    }

    @Test func everyMatchingPairPlaysTheSameTouchDragReleaseBeats() {
        typealias Step = ComprehensionTutorial.MatchingStep
        let steps = ComprehensionTutorial.matchingTransitions.map(\.step)
        let pairs = ComprehensionTutorial.matchingPairs.indices

        #expect(steps == pairs.flatMap { [Step.touch(pair: $0), .drag(pair: $0), .release(pair: $0)] } + [.completed])
        #expect(Step.waiting.handSpot == .offscreen)
        #expect(Step.touch(pair: 1).handSpot == .fruitDot(pair: 1))
        #expect(Step.drag(pair: 1).handSpot == .colorDot(pair: 1))
        #expect(Step.touch(pair: 1).handIsPressing)
        #expect(!Step.release(pair: 1).handIsPressing)
        #expect(!Step.completed.showsHand)
    }

    @Test func eachLineIsDrawnInOneDragAndStaysDrawn() {
        typealias Step = ComprehensionTutorial.MatchingStep

        #expect(Step.touch(pair: 0).lineProgress(forPair: 0) == 0)
        #expect(Step.drag(pair: 0).lineProgress(forPair: 0) == 1)
        #expect(Step.touch(pair: 1).lineProgress(forPair: 0) == 1)
        #expect(Step.touch(pair: 1).lineProgress(forPair: 1) == 0)
        #expect(Step.release(pair: 2).lineProgress(forPair: 2) == 1)
        #expect(Step.touch(pair: 0).activeItems == ["banana"])
        #expect(Step.drag(pair: 0).activeItems == ["banana", "yellow"])
        #expect(Step.completed.activeItems.isEmpty)
    }

    @Test func everyPairUsesTheSameTiming() {
        let transitions = ComprehensionTutorial.matchingTransitions
        let pairCount = ComprehensionTutorial.matchingPairs.count
        let beats = (0..<pairCount).map { pair in
            transitions[pair * 3 ..< pair * 3 + 3].map(\.duration)
        }

        #expect(Set(beats).count == 1)
    }

    @Test func matchingTutorialWaitsForEachAnimationPlusItsDelay() {
        let transitions = ComprehensionTutorial.matchingTransitions

        #expect(ComprehensionTutorial.matchingPause(before: 0) == transitions[0].delay)
        for index in transitions.indices.dropFirst() {
            let expected = transitions[index - 1].duration + transitions[index].delay
            #expect(abs(ComprehensionTutorial.matchingPause(before: index) - expected) < 0.0001)
        }
        #expect(transitions.last?.curve == .easeOut)
    }

    @Test func skippingMatchingTutorialInvalidatesItsPlayback() async {
        let vm = makeMatching()
        vm.didTapHowToPlay()
        let playback = Task { await vm.playTutorial(reduceMotion: false) }

        vm.didTapDismissTutorial()
        await playback.value

        #expect(!vm.isShowingTutorial)
        #expect(vm.tutorialStep == .waiting)
    }
}
