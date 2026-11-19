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

    let prompt: String
    let instruction: String
    private(set) var state: State = .answering
    private(set) var slots: [Slot] = []
    private(set) var pool: [Card] = []

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

    func mark(for slot: Slot) -> Mark? {
        guard state != .answering, let card = slot.card else { return nil }
        return card.id == correctOrder[slot.number - 1].id ? .correct : .incorrect
    }

    // MARK: - User actions

    func didTapPoolCard(_ card: Card) {
        guard state == .answering,
              let index = slots.firstIndex(where: { $0.card == nil }) else { return }
        slots[index].card = card
        pool.removeAll { $0.id == card.id }
    }

    func didTapSlot(_ slot: Slot) {
        guard state == .answering,
              let card = slot.card,
              let index = slots.firstIndex(where: { $0.id == slot.id }) else { return }
        slots[index].card = nil
        pool.append(card)
    }

    func didTapCheck() {
        guard canCheck else { return }
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

    private func reset() {
        state = .answering
        slots = correctOrder.indices.map { Slot(number: $0 + 1, card: nil) }
        var mixed = correctOrder
        if mixed.count > 1 { mixed.swapAt(0, 1) }
        pool = mixed
    }
}
