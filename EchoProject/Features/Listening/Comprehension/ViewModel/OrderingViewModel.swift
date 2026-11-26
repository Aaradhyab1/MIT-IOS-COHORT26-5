import Foundation
import Observation

@Observable
@MainActor
final class OrderingViewModel {

    enum State: Equatable {
        case answering
        case correct
        case incorrect
    }

    enum Mark: Equatable {
        case correct
        case incorrect
    }

    struct Card: Identifiable, Hashable {
        let id: String
        let text: String
        let image: String?
    }

    struct Slot: Identifiable, Hashable {
        let number: Int
        var card: Card?
        var id: Int { number }
    }

    /// Where a dragged card would land if the finger lifted now.
    enum DropTarget: Hashable {
        case slot(Int)
        case pool
    }

    let prompt: String
    let instruction: String
    private(set) var state: State = .answering
    private(set) var slots: [Slot] = []
    private(set) var pool: [Card] = []
    /// Every card in its starting, mixed-up order. Each card keeps this spot as its home
    /// in the pile, so the pile never reshuffles while the child plays.
    private(set) var pile: [Card] = []
    /// The card under the child's finger, and where it would land.
    private(set) var draggingCardId: String?
    private(set) var dropTarget: DropTarget?
    /// Goes up every time a card lands in a place, for the drop haptic.
    private(set) var placementRevision = 0
    private(set) var isShowingTutorial = false
    private(set) var tutorialStep: ComprehensionTutorial.OrderingStep = .waiting
    private(set) var tutorialPlaybackID = 0

    private let correctOrder: [Card]
    private var attempts = 0
    private let onFinished: (_ correctFirstTime: Bool) -> Void

    init(item: ExerciseItem, onFinished: @escaping (_ correctFirstTime: Bool) -> Void) {
        prompt = item.prompt ?? ""
        instruction = item.text ?? ""
        correctOrder = (item.options ?? []).map { Card(id: $0.id, text: $0.label, image: $0.image) }
        self.onFinished = onFinished
        reset()
    }

    // MARK: - Shown on screen

    var title: String {
        switch state {
        case .answering: prompt
        case .correct: "Correct!"
        case .incorrect: "Not quite!"
        }
    }

    var subtitle: String {
        switch state {
        case .answering: instruction
        case .correct: "You put the events in the right order."
        case .incorrect: "Some events are not in the right order."
        }
    }

    var canCheck: Bool {
        state == .answering && slots.allSatisfy { $0.card != nil }
    }

    var tutorialHasStarted: Bool { tutorialStep.hasStarted }
    var tutorialIsComplete: Bool { tutorialStep.isCompleted }
    var tutorialCanSkip: Bool { tutorialHasStarted && !tutorialIsComplete }
    var tutorialHandTarget: String? { tutorialStep.handTarget }

    var tutorialPool: [ComprehensionTutorial.OrderingCard] {
        let placedIDs = Set(tutorialPlacedIDs)
        return ComprehensionTutorial.orderingCards.filter { !placedIDs.contains($0.id) }
    }

    func tutorialCard(forSlot index: Int) -> ComprehensionTutorial.OrderingCard? {
        guard tutorialPlacedIDs.indices.contains(index) else { return nil }
        let id = tutorialPlacedIDs[index]
        return ComprehensionTutorial.orderingCards.first { $0.id == id }
    }

    var isDragging: Bool { draggingCardId != nil }

    /// True while the dragged card came from one of the numbered places.
    var isDraggingFromSlot: Bool {
        guard let id = draggingCardId else { return false }
        return slots.contains { $0.card?.id == id }
    }

    /// The first numbered place that is still empty, for tap-to-place.
    var nextEmptySlotNumber: Int? {
        slots.first { $0.card == nil }?.number
    }

    func isDragging(_ card: Card) -> Bool {
        draggingCardId == card.id
    }

    func isDropTarget(_ slot: Slot) -> Bool {
        dropTarget == .slot(slot.number)
    }

    func mark(for slot: Slot) -> Mark? {
        guard state != .answering, let card = slot.card else { return nil }
        return card.id == correctOrder[slot.number - 1].id ? .correct : .incorrect
    }

    // MARK: - User actions

    func didTapHowToPlay() {
        guard !isShowingTutorial else { return }
        didCancelDrag()
        tutorialPlaybackID += 1
        tutorialStep = .waiting
        isShowingTutorial = true
    }

    func didTapDismissTutorial() {
        stopTutorialPlayback()
    }

    func didLeaveTutorial() {
        stopTutorialPlayback()
    }

    func playTutorial(reduceMotion: Bool) async {
        guard isShowingTutorial else { return }
        let playbackID = tutorialPlaybackID

        if reduceMotion {
            tutorialStep = .completed
            return
        }

        for transition in ComprehensionTutorial.orderingTransitions {
            guard await waitForTutorialTransition(after: transition.delay, playbackID: playbackID) else { return }
            tutorialStep = transition.step
        }
    }

    // MARK: - User actions: dragging cards

    /// The finger picked up a card, from the pile or from a numbered place.
    func didBeginDragging(_ card: Card) {
        guard state == .answering, !isShowingTutorial, draggingCardId == nil else { return }
        draggingCardId = card.id
        dropTarget = nil
    }

    /// The finger moved over a place, over the pile, or over nothing.
    func didMoveDrag(over target: DropTarget?) {
        guard draggingCardId != nil else { return }
        dropTarget = target
    }

    /// The finger lifted: drop the card where it is, or leave it where it came from.
    func didEndDrag() {
        defer {
            draggingCardId = nil
            dropTarget = nil
        }
        guard let id = draggingCardId, let card = card(withId: id) else { return }
        switch dropTarget {
        case .slot(let number): place(card, inSlot: number)
        case .pool: returnToPool(card)
        case nil: break
        }
    }

    /// The system cancelled the drag (for example, a phone call).
    func didCancelDrag() {
        draggingCardId = nil
        dropTarget = nil
    }

    /// Puts a card in a numbered place. A card already there swaps to where the moved card
    /// came from: the other place, or back to the pile. Also used by the VoiceOver actions.
    func place(_ card: Card, inSlot number: Int) {
        guard state == .answering,
              let target = slots.firstIndex(where: { $0.number == number }),
              slots[target].card?.id != card.id else { return }

        let displaced = slots[target].card
        if let origin = slots.firstIndex(where: { $0.card?.id == card.id }) {
            slots[origin].card = displaced
        } else {
            pool.removeAll { $0.id == card.id }
            if let displaced { pool.append(displaced) }
        }
        slots[target].card = card
        placementRevision += 1
    }

    /// Takes a placed card out of its place and puts it back in the pile.
    func returnToPool(_ card: Card) {
        guard state == .answering,
              let index = slots.firstIndex(where: { $0.card?.id == card.id }) else { return }
        slots[index].card = nil
        pool.append(card)
    }

    // MARK: - User actions: answer

    func didTapCheck() {
        guard canCheck else { return }
        didCancelDrag()
        attempts += 1
        let placed = slots.compactMap(\.card?.id)
        state = placed == correctOrder.map(\.id) ? .correct : .incorrect
    }

    func didTapTryAgain() {
        reset()
    }

    func didTapContinue() {
        onFinished(attempts == 1)
    }

    // MARK: - Private

    private func card(withId id: String) -> Card? {
        pool.first { $0.id == id } ?? slots.lazy.compactMap(\.card).first { $0.id == id }
    }

    private var tutorialPlacedIDs: [String] {
        let storyOrder = ["seed", "water", "flower"]
        return Array(storyOrder.prefix(tutorialStep.placedCardCount))
    }

    private func stopTutorialPlayback() {
        guard isShowingTutorial else { return }
        isShowingTutorial = false
        tutorialPlaybackID += 1
        tutorialStep = .waiting
    }

    private func waitForTutorialTransition(after delay: TimeInterval, playbackID: Int) async -> Bool {
        do {
            try await Task.sleep(for: .seconds(delay))
        } catch {
            return false
        }

        return !Task.isCancelled && isShowingTutorial && tutorialPlaybackID == playbackID
    }

    private func reset() {
        state = .answering
        didCancelDrag()
        slots = correctOrder.indices.map { Slot(number: $0 + 1, card: nil) }
        var mixed = correctOrder
        if mixed.count > 1 { mixed.swapAt(0, 1) }
        pool = mixed
        pile = mixed
    }
}
