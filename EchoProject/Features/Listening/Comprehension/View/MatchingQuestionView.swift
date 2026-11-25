import SwiftUI

struct MatchingQuestionView: View {
    let vm: MatchingViewModel

    var body: some View {
        Group {
            if vm.isShowingTutorial {
                ComprehensionMatchingTutorialView(vm: vm)
            } else {
                MatchingQuestionContent(vm: vm)
            }
        }
    }
}

private struct MatchingQuestionContent: View {
    let vm: MatchingViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var subtitleColor: Color {
        switch vm.state {
        case .answering, .incorrect: EchoColor.textSecondary
        case .correct: ComprehensionColor.correct
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                QuestionHeader(
                    title: vm.prompt,
                    subtitle: vm.subtitle,
                    onHowToPlay: vm.didTapHowToPlay,
                    subtitleColor: subtitleColor
                )

                MatchingBoard(vm: vm)
                    .padding(.top, 13)
            }
            .padding(.horizontal, EchoSpacing.screenHorizontal)
            .padding(.top, ComprehensionLayout.questionTop)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDisabled(vm.isConnecting)
        .safeAreaInset(edge: .bottom) {
            bottomButton
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: vm.state)
        .sensoryFeedback(trigger: vm.state) { _, newState in
            switch newState {
            case .answering: nil
            case .correct: .success
            case .incorrect: .error
            }
        }
    }

    @ViewBuilder
    private var bottomButton: some View {
        switch vm.state {
        case .answering:
            ComprehensionBottomButton(title: "Check answer", isEnabled: vm.canCheck, action: vm.didTapCheck)
        case .correct:
            ComprehensionBottomButton(title: "Continue", action: vm.didTapContinue)
        case .incorrect:
            ComprehensionBottomButton(title: "Try again", action: vm.didTapTryAgain)
        }
    }
}

/// The cards plus the lines between them. Every card reports its frame in the board's
/// coordinate space, so the lines, dots and drop targets all share one set of positions.
private struct MatchingBoard: View {
    let vm: MatchingViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tileFrames: [MatchingViewModel.Endpoint: CGRect] = [:]
    @State private var fingerLocation: CGPoint?
    /// Resets to false by itself when a drag ends or the system cancels it.
    @GestureState private var isDragging = false

    private static let space = "matchingBoard"
    private typealias Endpoint = MatchingViewModel.Endpoint
    private typealias Layout = ComprehensionLayout

    var body: some View {
        VStack(spacing: Layout.matchingRowSpacing) {
            ForEach(vm.rows) { row in
                HStack(spacing: Layout.matchingTileGap) {
                    tile(row.left, side: .left)
                    tile(row.right, side: .right)
                }
            }
        }
        .overlay { linesAndDots.allowsHitTesting(false) }
        .coordinateSpace(.named(Self.space))
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: vm.connections)
        .animation(reduceMotion ? nil : .snappy(duration: 0.15), value: vm.dragTarget)
        .sensoryFeedback(.selection, trigger: vm.dragTarget) { _, newTarget in newTarget != nil }
        .sensoryFeedback(.impact(weight: .medium), trigger: vm.connectionRevision)
        .onChange(of: isDragging) { _, dragging in
            guard !dragging, vm.isConnecting else { return }
            fingerLocation = nil
            vm.didCancelConnecting()
        }
    }

    // MARK: - Cards

    private func tile(_ tile: MatchingViewModel.Tile, side: MatchingViewModel.Side) -> some View {
        let endpoint = Endpoint(side: side, tileId: tile.id)
        return MatchingTileView(tile: tile, isHighlighted: vm.isHighlighted(endpoint))
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .named(Self.space))
            } action: { frame in
                tileFrames[endpoint] = frame
            }
            .highPriorityGesture(connectGesture(from: endpoint), including: vm.state == .answering ? .all : .subviews)
            .accessibilityElement(children: .combine)
            .accessibilityValue(accessibilityValue(for: endpoint))
            .accessibilityHint(vm.state == .answering ? "Drag to a card on the other side to connect them" : "")
            .accessibilityActions {
                if vm.state == .answering {
                    ForEach(vm.candidates(for: endpoint), id: \.self) { candidate in
                        if let other = vm.tile(for: candidate) {
                            Button("Connect to \(other.label)") { vm.connect(endpoint, candidate) }
                        }
                    }
                    if vm.isConnected(endpoint) {
                        Button("Remove line") { vm.disconnect(endpoint) }
                    }
                }
            }
    }

    private func accessibilityValue(for endpoint: Endpoint) -> String {
        guard let partner = vm.connectedTile(for: endpoint) else { return "Not connected" }
        switch vm.mark(for: endpoint) {
        case .correct: return "Connected to \(partner.label). Correct"
        case .incorrect: return "Connected to \(partner.label). Incorrect"
        case nil: return "Connected to \(partner.label)"
        }
    }

    // MARK: - Dragging a line

    private func connectGesture(from endpoint: Endpoint) -> some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .named(Self.space))
            .updating($isDragging) { _, dragging, _ in dragging = true }
            .onChanged { value in
                if vm.dragOrigin == nil {
                    vm.didBeginConnecting(from: endpoint)
                }
                guard vm.dragOrigin == endpoint else { return }
                fingerLocation = value.location
                vm.didMoveConnection(over: card(at: value.location, oppositeTo: endpoint.side))
            }
            .onEnded { _ in
                guard vm.dragOrigin == endpoint else { return }
                fingerLocation = nil
                vm.didEndConnecting()
            }
    }

    /// The card under the finger on the other side, with a little slop so it's easy to hit.
    private func card(at point: CGPoint, oppositeTo side: MatchingViewModel.Side) -> Endpoint? {
        tileFrames.first { endpoint, frame in
            endpoint.side != side && frame.insetBy(dx: -Layout.matchingDropSlop, dy: -Layout.matchingDropSlop / 2).contains(point)
        }?.key
    }

    // MARK: - Lines and dots

    private func dotCenter(_ endpoint: Endpoint) -> CGPoint? {
        guard let frame = tileFrames[endpoint] else { return nil }
        let x = endpoint.side == .left
            ? frame.maxX + Layout.matchingDotInset
            : frame.minX - Layout.matchingDotInset
        return CGPoint(x: x, y: frame.midY)
    }

    private func lineColor(_ mark: MatchingViewModel.Mark?) -> Color {
        switch mark {
        case .correct: ComprehensionColor.matchCorrect
        case .incorrect: ComprehensionColor.matchIncorrect
        case nil: ComprehensionColor.matchLine
        }
    }

    @ViewBuilder
    private var linesAndDots: some View {
        ZStack(alignment: .topLeading) {
            ForEach(vm.connections) { connection in
                let left = Endpoint(side: .left, tileId: connection.leftId)
                let right = Endpoint(side: .right, tileId: connection.rightId)
                if let start = dotCenter(left), let end = dotCenter(right) {
                    MatchLine(start: start, end: end)
                        .stroke(
                            lineColor(vm.mark(for: connection)),
                            style: StrokeStyle(lineWidth: Layout.matchingLineWidth, lineCap: .round)
                        )
                        .transition(.opacity)

                    if let mark = vm.mark(for: connection) {
                        MatchBadge(mark: mark)
                            .position(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }

            if let origin = vm.dragOrigin, let start = dotCenter(origin), let finger = fingerLocation {
                let end = vm.dragTarget.flatMap(dotCenter) ?? finger
                MatchLine(start: start, end: end)
                    .stroke(
                        ComprehensionColor.matchLine.opacity(vm.dragTarget == nil ? 0.6 : 1),
                        style: StrokeStyle(lineWidth: Layout.matchingLineWidth, lineCap: .round)
                    )
            }

            ForEach(Array(tileFrames.keys), id: \.self) { endpoint in
                if let center = dotCenter(endpoint) {
                    MatchDot(style: dotStyle(for: endpoint))
                        .position(center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func dotStyle(for endpoint: Endpoint) -> MatchDot.Style {
        if let mark = vm.mark(for: endpoint) {
            return mark == .correct ? .correct : .incorrect
        }
        return vm.isConnected(endpoint) || vm.isHighlighted(endpoint) ? .active : .idle
    }
}

private struct MatchingTileView: View {
    let tile: MatchingViewModel.Tile
    let isHighlighted: Bool

    var body: some View {
        VStack(spacing: EchoSpacing.s) {
            Image(tile.image ?? "")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 54)
                .accessibilityHidden(true)
            Text(tile.label)
                .echoFont(.supporting, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, EchoSpacing.s)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, minHeight: ComprehensionLayout.matchingTileHeight, alignment: .top)
        .background(ComprehensionColor.tileFill, in: .rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    isHighlighted ? ComprehensionColor.matchTileHighlight : ComprehensionColor.tileStroke,
                    lineWidth: isHighlighted ? ComprehensionLayout.matchingHighlightStroke : 1
                )
        )
        .contentShape(.rect(cornerRadius: 24))
    }
}

/// A straight line from one dot to another.
private struct MatchLine: Shape {
    var start: CGPoint
    var end: CGPoint

    var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
        get { AnimatablePair(start.animatableData, end.animatableData) }
        set {
            start.animatableData = newValue.first
            end.animatableData = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
    }
}

/// The connector dot on a card's inner edge.
private struct MatchDot: View {
    enum Style {
        case idle
        case active
        case correct
        case incorrect
    }

    let style: Style

    private var fill: Color {
        switch style {
        case .idle: ComprehensionColor.matchDotIdleFill
        case .active: ComprehensionColor.matchLine
        case .correct: ComprehensionColor.matchCorrect
        case .incorrect: ComprehensionColor.matchIncorrect
        }
    }

    var body: some View {
        Circle()
            .fill(fill)
            .strokeBorder(style == .idle ? ComprehensionColor.matchDotIdleStroke : .white, lineWidth: ComprehensionLayout.matchingDotStroke)
            .frame(width: ComprehensionLayout.matchingDotSize, height: ComprehensionLayout.matchingDotSize)
    }
}

/// ✓ or × in the middle of a line after "Check answer".
private struct MatchBadge: View {
    let mark: MatchingViewModel.Mark

    var body: some View {
        Image(systemName: mark == .correct ? "checkmark" : "xmark")
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(mark == .correct ? ComprehensionColor.matchBadgeCorrect : ComprehensionColor.matchBadgeIncorrect)
            .frame(width: ComprehensionLayout.matchingBadgeSize, height: ComprehensionLayout.matchingBadgeSize)
            .background(ComprehensionColor.matchBadgeFill, in: Circle())
            .overlay(
                Circle().strokeBorder(
                    mark == .correct ? ComprehensionColor.matchCorrect : ComprehensionColor.matchIncorrect,
                    lineWidth: 2
                )
            )
    }
}

#Preview("Matching") {
    let question = ExerciseItem(
        id: "preview.matching",
        prompt: "Who did what?",
        text: "Draw a line from each character to what they did.",
        options: [
            Option(id: "bird", label: "Bird", image: "img_match-bird"),
            Option(id: "cat", label: "Cat", image: "img_match-cat"),
            Option(id: "turtle", label: "Turtle", image: "img_match-turtle")
        ]
    )
    let answers = ExerciseItem(
        id: "preview.matching-answers",
        options: [
            Option(id: "bird", label: "Ate the bread", image: "img_match-bird-action"),
            Option(id: "cat", label: "Chased the bird", image: "img_match-cat-action"),
            Option(id: "turtle", label: "Saw the bread", image: "img_match-turtle-action")
        ]
    )
    return MatchingQuestionView(vm: MatchingViewModel(question: question, answers: answers) { _ in })
        .echoExerciseBackground()
}
