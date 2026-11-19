import Foundation
import Observation

@Observable
@MainActor
final class MatchingViewModel {

    enum State: Equatable {
        case answering
        case correct
        case incorrect
    }

    enum Mark: Equatable {
        case correct
        case incorrect
    }

    struct Tile: Identifiable, Hashable {
        let id: String
        let label: String
        let image: String?
    }

    struct Row: Identifiable, Hashable {
        let id: Int
        let left: Tile
        let right: Tile
    }

    let prompt: String
    let instruction: String
    let rows: [Row]
    private(set) var state: State = .answering
    private(set) var selectedLeftId: String?
    private(set) var matches: [String: String] = [:]

    private var attempts = 0
    private let onFinished: (_ correctFirstTime: Bool) -> Void

    init(question: ExerciseItem, answers: ExerciseItem, onFinished: @escaping (_ correctFirstTime: Bool) -> Void) {
        prompt = question.prompt ?? ""
        instruction = question.text ?? ""
        let left = (question.options ?? []).map { Tile(id: $0.id, label: $0.label, image: $0.image) }
        let right = (answers.options ?? []).map { Tile(id: $0.id, label: $0.label, image: $0.image) }
        rows = zip(left, right).enumerated().map { index, pair in
            Row(id: index, left: pair.0, right: pair.1)
        }
        self.onFinished = onFinished
    }

    // MARK: - Shown on screen

    var subtitle: String {
        switch state {
        case .answering: instruction
        case .correct: "All matches are correct!"
        case .incorrect: "Not quite yet. Try the pairs again."
        }
    }

    var canCheck: Bool {
        state == .answering && matches.count == rows.count
    }

    func isSelected(_ tile: Tile) -> Bool {
        selectedLeftId == tile.id
    }

    func pairNumber(forLeft tile: Tile) -> Int? {
        guard matches[tile.id] != nil else { return nil }
        return rows.firstIndex { $0.left.id == tile.id }.map { $0 + 1 }
    }

    func pairNumber(forRight tile: Tile) -> Int? {
        guard let leftId = leftId(matchedTo: tile) else { return nil }
        return rows.firstIndex { $0.left.id == leftId }.map { $0 + 1 }
    }

    func mark(forLeft tile: Tile) -> Mark? {
        guard state != .answering, let rightId = matches[tile.id] else { return nil }
        return rightId == tile.id ? .correct : .incorrect
    }

    func mark(forRight tile: Tile) -> Mark? {
        guard state != .answering, let leftId = leftId(matchedTo: tile) else { return nil }
        return leftId == tile.id ? .correct : .incorrect
    }

    // MARK: - User actions

    func didTapLeft(_ tile: Tile) {
        guard state == .answering else { return }
        selectedLeftId = selectedLeftId == tile.id ? nil : tile.id
    }

    func didTapRight(_ tile: Tile) {
        guard state == .answering, let leftId = selectedLeftId else { return }
        if let previous = self.leftId(matchedTo: tile) {
            matches[previous] = nil
        }
        matches[leftId] = tile.id
        selectedLeftId = nil
    }

    func didTapCheck() {
        guard canCheck else { return }
        attempts += 1
        state = matches.allSatisfy { $0.key == $0.value } ? .correct : .incorrect
    }

    func didTapTryAgain() {
        matches = [:]
        selectedLeftId = nil
        state = .answering
    }

    func didTapContinue() {
        onFinished(attempts == 1)
    }

    // MARK: - Private

    private func leftId(matchedTo right: Tile) -> String? {
        matches.first { $0.value == right.id }?.key
    }
}
