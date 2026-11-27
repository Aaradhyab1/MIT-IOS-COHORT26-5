import Testing
@testable import EchoProject

/// Conversation: matching the child's answer to a choice, and the ViewModel on dummy services.
@MainActor
struct ConversationTests {

    private let flavours = [
        ConversationChoice(id: "chocolate", label: "Chocolate", imageName: nil),
        ConversationChoice(id: "vanilla", label: "Vanilla", imageName: nil),
        ConversationChoice(id: "strawberry", label: "Strawberry", imageName: nil)
    ]

    // MARK: - ChoiceMatcher

    @Test func findsTheChoiceInsideASentence() {
        #expect(ChoiceMatcher.choice(in: "I want chocolate please", from: flavours)?.id == "chocolate")
        #expect(ChoiceMatcher.choice(in: "Vanilla!", from: flavours)?.id == "vanilla")
    }

    @Test func pluralsAndSmallMishearingsStillCount() {
        #expect(ChoiceMatcher.choice(in: "strawberries", from: flavours)?.id == "strawberry")
        #expect(ChoiceMatcher.choice(in: "chocolat", from: flavours)?.id == "chocolate")
    }

    @Test func somethingElseOrTwoChoicesDoNotCount() {
        #expect(ChoiceMatcher.choice(in: "mango", from: flavours) == nil)
        #expect(ChoiceMatcher.choice(in: "chocolate and vanilla", from: flavours) == nil)
        #expect(ChoiceMatcher.choice(in: "", from: flavours) == nil)
    }

    @Test func shortWordsMustMatchExactly() {
        let cupOrCone = [
            ConversationChoice(id: "cup", label: "Cup", imageName: nil),
            ConversationChoice(id: "cone", label: "Cone", imageName: nil)
        ]
        #expect(ChoiceMatcher.choice(in: "a cone please", from: cupOrCone)?.id == "cone")
        #expect(ChoiceMatcher.choice(in: "come", from: cupOrCone) == nil)
    }

    // MARK: - Data

    @Test func conversationHasThreeTurnsWithTwoOrThreeChoices() {
        let content = InMemoryContentRepository()
        let items = content.exercise(id: "conversation.ice-cream-shop")?.items ?? []
        #expect(items.count == 3)
        for item in items {
            #expect((2...3).contains(item.options?.count ?? 0), "\(item.id) needs 2 or 3 choices")
        }
    }

    @Test func retryLineListsOnlyTheChoices() {
        let item = ExerciseItem(id: "t", text: "Which one?", options: [
            Option(id: "cup", label: "Cup"), Option(id: "cone", label: "Cone")
        ])
        #expect(ConversationTurn(item).retryLine == "Sorry, you can only choose cup or cone. Which one would you like?")
        #expect(ConversationTurn.listed(["a", "b", "c"]) == "a, b or c")
    }

    // MARK: - ViewModel

    private func makeViewModel(heard: String? = nil) -> (ConversationViewModel, AppContainer) {
        let container = AppContainer.dummy(startPastOnboarding: true)
        let speech = DummySpeechRecognitionService()
        speech.heardText = heard
        let vm = ConversationViewModel(
            exerciseId: "conversation.ice-cream-shop",
            content: container.content,
            recording: DummyRecordingService(),
            speech: speech,
            voice: DummySpeechSynthesisService(),
            progress: container.progress,
            router: container.router
        )
        return (vm, container)
    }

    /// Start, wait for the shopkeeper, record, stop, wait for checking.
    private func answerFirstTurn(_ vm: ConversationViewModel) async throws {
        vm.didTapStart()
        try await Task.sleep(for: .milliseconds(900))     // shopkeeper says the question
        #expect(vm.phase == .yourTurn)
        vm.didTapSpeak()
        try await Task.sleep(for: .milliseconds(100))
        #expect(vm.phase == .recording)
        vm.didTapStop()
        try await Task.sleep(for: .milliseconds(800))     // speech recognition
    }

    @Test func startsOnTheIntro() {
        let (vm, _) = makeViewModel()
        #expect(vm.phase == .intro)
        #expect(vm.turnText == "Turn 1 of 3")
    }

    @Test func shopkeeperConfirmsTheAnswerAndAsksTheNextQuestion() async throws {
        let (vm, _) = makeViewModel(heard: "I would like vanilla")
        try await answerFirstTurn(vm)
        #expect(vm.order.map(\.label) == ["Vanilla"])
        #expect(vm.childLine == "Vanilla")
        #expect(vm.turnText == "Turn 2 of 3")
        #expect(vm.shopkeeperLine.hasPrefix("Vanilla"))
        #expect(vm.shopkeeperLine.hasSuffix("Would you like it in a cup or a cone?"))
        vm.stopAll()
    }

    @Test func somethingElseMakesTheShopkeeperAskAgain() async throws {
        let (vm, _) = makeViewModel(heard: "mango")
        try await answerFirstTurn(vm)
        #expect(vm.turnText == "Turn 1 of 3")
        #expect(vm.shopkeeperLine.hasPrefix("Sorry, you can only choose chocolate, vanilla or strawberry"))
        #expect(vm.order.isEmpty)
        vm.stopAll()
    }

    @Test func iceCreamPictureIsNamedAfterTheChoices() {
        let item = ExerciseItem(id: "t", text: "Which one?", options: [Option(id: "cup", label: "Cup")], hint: "A {choice}, coming up!")
        let turn = ConversationTurn(item)
        #expect(turn.confirmation(for: turn.choices[0]) == "A cup, coming up!")
    }

    @Test func recordingStopsByItselfOneSecondAfterAChoiceIsHeard() async throws {
        let (vm, _) = makeViewModel(heard: "chocolate please")
        vm.didTapStart()
        try await Task.sleep(for: .milliseconds(900))     // shopkeeper says the question
        vm.didTapSpeak()
        try await Task.sleep(for: .milliseconds(1_200))   // heard after 0.8 s, still waiting 1 s
        #expect(vm.phase == .recording)
        try await Task.sleep(for: .milliseconds(1_500))   // stopped and checked
        #expect(vm.order.map(\.label) == ["Chocolate"])
        vm.stopAll()
    }

    @Test func backDuringTheConversationOpensTheSharedLeaveOverlay() async throws {
        let (vm, container) = makeViewModel()
        vm.didTapStart()
        try await Task.sleep(for: .milliseconds(100))
        vm.didTapBack()
        #expect(container.router.overlay == .leavePractice)
        vm.stopAll()
    }
}
