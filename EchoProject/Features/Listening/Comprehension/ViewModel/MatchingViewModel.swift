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

    enum Side: Hashable {
        case left
        case right
    }

    /// One end of a line: a card on one side of the board.
    struct Endpoint: Hashable {
        let side: Side
        let tileId: String
    }

    /// A line the child has drawn from a character to an action.
    struct Connection: Identifiable, Hashable {
        let leftId: String
        let rightId: String
        var id: String { leftId }
    }

    let prompt: String
    let instruction: String
    let rows: [Row]
    private(set) var state: State = .answering
    /// left tile id → right tile id
    private(set) var matches: [String: String] = [:]
    /// The card a line is being dragged from, and the card under the finger.
    private(set) var dragOrigin: Endpoint?
    private(set) var dragTarget: Endpoint?
    /// Goes up every time a line is connected, for the connect haptic.
    private(set) var connectionRevision = 0

    private(set) var isShowingTutorial = false
    private(set) var tutorialStep: ComprehensionTutorial.MatchingStep = .waiting
    /// The Figma transition that led into `tutorialStep`, so the view animates it the same way.
    private(set) var tutorialTransition: (duration: TimeInterval, curve: ComprehensionTutorial.Curve) =
        (ComprehensionTutorial.animationDuration, .easeInOut)
    private(set) var tutorialPlaybackID = 0

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

    var connections: [Connection] {
        rows.compactMap { row in
            matches[row.left.id].map { Connection(leftId: row.left.id, rightId: $0) }
        }
    }

    var isConnecting: Bool { dragOrigin != nil }

    func isConnected(_ endpoint: Endpoint) -> Bool {
        partner(of: endpoint) != nil
    }

    /// Blue outline: the card being dragged from, or the card the line would land on.
    func isHighlighted(_ endpoint: Endpoint) -> Bool {
        endpoint == dragOrigin || endpoint == dragTarget
    }

    func mark(for connection: Connection) -> Mark? {
        guard state != .answering else { return nil }
        return connection.leftId == connection.rightId ? .correct : .incorrect
    }

    func mark(for endpoint: Endpoint) -> Mark? {
        guard let partner = partner(of: endpoint) else { return nil }
        let connection = endpoint.side == .left
            ? Connection(leftId: endpoint.tileId, rightId: partner)
            : Connection(leftId: partner, rightId: endpoint.tileId)
        return mark(for: connection)
    }

    func tile(for endpoint: Endpoint) -> Tile? {
        rows.lazy.map { endpoint.side == .left ? $0.left : $0.right }.first { $0.id == endpoint.tileId }
    }

    /// The cards on the other side, which this card can be connected to.
    func candidates(for endpoint: Endpoint) -> [Endpoint] {
        rows.map { row in
            endpoint.side == .left
                ? Endpoint(side: .right, tileId: row.right.id)
                : Endpoint(side: .left, tileId: row.left.id)
        }
    }

    /// The card this one is connected to, for VoiceOver.
    func connectedTile(for endpoint: Endpoint) -> Tile? {
        guard let partner = partner(of: endpoint) else { return nil }
        return tile(for: Endpoint(side: endpoint.side == .left ? .right : .left, tileId: partner))
    }

    // MARK: - Tutorial (shown on screen)

    var tutorialHasStarted: Bool { tutorialStep.hasStarted }
    var tutorialIsComplete: Bool { tutorialStep.isCompleted }
    var tutorialCanSkip: Bool { !tutorialIsComplete }
    var tutorialShowsHand: Bool { tutorialStep.showsHand }
    var tutorialHandSpot: ComprehensionTutorial.MatchingHandSpot { tutorialStep.handSpot }
    /// On the last frame every line and dot turns green, as in Figma's checked frame.
    var tutorialIsChecked: Bool { tutorialIsComplete }

    func tutorialLineProgress(forPair index: Int) -> Double {
        tutorialStep.lineProgress(forPair: index)
    }

    func tutorialPairIsConnected(at index: Int) -> Bool {
        tutorialLineProgress(forPair: index) >= 1
    }

    func tutorialItemIsActive(_ id: String) -> Bool {
        tutorialStep.activeItems.contains(id)
    }

    // MARK: - User actions: connecting

    /// The finger went down on a card. Dragging from a card that already has a line picks
    /// that line up, so it can be moved to another card or dropped to remove it.
    func didBeginConnecting(from origin: Endpoint) {
        guard state == .answering, !isShowingTutorial, dragOrigin == nil else { return }
        disconnect(origin)
        dragOrigin = origin
        dragTarget = nil
    }

    /// The finger moved. Only a card on the other side can be the target.
    func didMoveConnection(over target: Endpoint?) {
        guard let origin = dragOrigin else { return }
        if let target, target.side != origin.side {
            dragTarget = target
        } else {
            dragTarget = nil
        }
    }

    /// The finger lifted: connect to the card under it, or connect nothing.
    func didEndConnecting() {
        defer {
            dragOrigin = nil
            dragTarget = nil
        }
        guard let origin = dragOrigin, let target = dragTarget else { return }
        connect(origin, target)
    }

    /// The system cancelled the drag (for example, a phone call).
    func didCancelConnecting() {
        dragOrigin = nil
        dragTarget = nil
    }

    /// Connects two cards on opposite sides. Each card has at most one line, so any line
    /// already on either card is replaced. Also used by the VoiceOver actions.
    func connect(_ first: Endpoint, _ second: Endpoint) {
        guard state == .answering, first.side != second.side else { return }
        let (leftTileId, rightTileId) = first.side == .left
            ? (first.tileId, second.tileId)
            : (second.tileId, first.tileId)
        if let previousLeft = self.leftId(matchedTo: rightTileId) {
            matches[previousLeft] = nil
        }
        matches[leftTileId] = rightTileId
        connectionRevision += 1
    }

    func disconnect(_ endpoint: Endpoint) {
        guard state == .answering else { return }
        switch endpoint.side {
        case .left:
            matches[endpoint.tileId] = nil
        case .right:
            if let leftTileId = self.leftId(matchedTo: endpoint.tileId) {
                matches[leftTileId] = nil
            }
        }
    }

    // MARK: - User actions: answer

    func didTapCheck() {
        guard canCheck else { return }
        didCancelConnecting()
        attempts += 1
        state = matches.allSatisfy { $0.key == $0.value } ? .correct : .incorrect
    }

    func didTapTryAgain() {
        matches = [:]
        didCancelConnecting()
        state = .answering
    }

    func didTapContinue() {
        onFinished(attempts == 1)
    }

    // MARK: - User actions: tutorial

    func didTapHowToPlay() {
        guard !isShowingTutorial else { return }
        didCancelConnecting()
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

    /// Plays the Figma flow frame by frame. Each wait covers the previous frame's animation
    /// plus Figma's "after delay", so the pacing matches the prototype.
    func playTutorial(reduceMotion: Bool) async {
        guard isShowingTutorial else { return }
        let playbackID = tutorialPlaybackID

        if reduceMotion {
            tutorialStep = .completed
            return
        }

        for (index, transition) in ComprehensionTutorial.matchingTransitions.enumerated() {
            let pause = ComprehensionTutorial.matchingPause(before: index)
            guard await waitForTutorialTransition(after: pause, playbackID: playbackID) else { return }
            tutorialTransition = (transition.duration, transition.curve)
            tutorialStep = transition.step
        }
    }

    // MARK: - Private

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

    private func partner(of endpoint: Endpoint) -> String? {
        switch endpoint.side {
        case .left: matches[endpoint.tileId]
        case .right: leftId(matchedTo: endpoint.tileId)
        }
    }

    private func leftId(matchedTo rightId: String) -> String? {
        matches.first { $0.value == rightId }?.key
    }
}
