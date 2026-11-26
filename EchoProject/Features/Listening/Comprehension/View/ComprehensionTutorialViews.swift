import SwiftUI

struct ComprehensionOrderingTutorialView: View {
    let vm: OrderingViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var cardNamespace

    private var animation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: ComprehensionTutorial.animationDuration)
    }

    var body: some View {
        ComprehensionTutorialScreen(
            title: ComprehensionTutorial.orderingTitle,
            subtitle: ComprehensionTutorial.orderingSubtitle,
            showsHeader: true,
            showsSkip: vm.tutorialCanSkip,
            isComplete: vm.tutorialIsComplete,
            isActive: vm.isShowingTutorial,
            playbackID: vm.tutorialPlaybackID,
            step: vm.tutorialStep,
            animation: animation,
            onSkip: vm.didTapDismissTutorial,
            play: vm.playTutorial,
            onDisappear: vm.didLeaveTutorial
        ) {
            ComprehensionOrderingTutorialBoard(vm: vm, namespace: cardNamespace)
                .padding(.horizontal, ComprehensionLayout.orderingTutorialHorizontalInset)
        }
    }
}

struct ComprehensionMatchingTutorialView: View {
    let vm: MatchingViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Each frame animates in with the duration and curve of its own Figma connection.
    private var animation: Animation? {
        guard !reduceMotion else { return nil }
        let transition = vm.tutorialTransition
        switch transition.curve {
        case .easeInOut: return .easeInOut(duration: transition.duration)
        case .easeOut: return .easeOut(duration: transition.duration)
        }
    }

    var body: some View {
        ComprehensionTutorialScreen(
            title: ComprehensionTutorial.matchingTitle,
            subtitle: ComprehensionTutorial.matchingSubtitle,
            showsHeader: true,
            showsSkip: vm.tutorialCanSkip,
            isComplete: vm.tutorialIsComplete,
            isActive: vm.isShowingTutorial,
            playbackID: vm.tutorialPlaybackID,
            step: vm.tutorialStep,
            animation: animation,
            boardTopGap: ComprehensionLayout.matchingTutorialHeaderToBoardGap,
            onSkip: vm.didTapDismissTutorial,
            play: vm.playTutorial,
            onDisappear: vm.didLeaveTutorial
        ) {
            ComprehensionMatchingTutorialBoard(vm: vm)
                .padding(.horizontal, ComprehensionLayout.matchingTutorialHorizontalInset)
        }
    }
}

private struct ComprehensionTutorialScreen<Step: Equatable, Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let subtitle: String
    let showsHeader: Bool
    let showsSkip: Bool
    let isComplete: Bool
    let isActive: Bool
    let playbackID: Int
    let step: Step
    let animation: Animation?
    var boardTopGap: CGFloat = ComprehensionLayout.tutorialHeaderToBoardGap
    let onSkip: () -> Void
    let play: (Bool) async -> Void
    let onDisappear: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    if showsSkip {
                        Button("Skip", action: onSkip)
                            .echoFont(.body, .semibold)
                            .foregroundStyle(ComprehensionColor.howToPlayText)
                            .frame(width: 60, height: ComprehensionLayout.tutorialButtonHeight)
                            .background(EchoColor.pillSurface, in: Capsule())
                            .buttonStyle(.plain)
                            .accessibilityHint("Returns to the activity")
                    }
                }
                .frame(height: ComprehensionLayout.tutorialButtonHeight)
                .padding(.top, ComprehensionLayout.tutorialButtonTopInset)
                .padding(.horizontal, EchoSpacing.screenHorizontal)

                VStack(spacing: EchoSpacing.s) {
                    Text(title)
                        .echoFont(.heading, .bold)
                        .foregroundStyle(EchoColor.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text(subtitle)
                        .echoFont(.body)
                        .foregroundStyle(ComprehensionColor.tutorialSubtitle)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, EchoSpacing.screenHorizontal)
                .opacity(showsHeader ? 1 : 0)
                .accessibilityHidden(!showsHeader)
                .padding(.top, ComprehensionLayout.tutorialHeaderTopGap)

                content
                    .padding(.top, boardTopGap)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isComplete {
                ComprehensionBottomButton(title: "Got it", action: onSkip)
                    .transition(reduceMotion ? .identity : .opacity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task(id: playbackID) {
            guard isActive else { return }
            await play(reduceMotion)
        }
        .onDisappear(perform: onDisappear)
        .animation(animation, value: step)
    }
}

private struct ComprehensionOrderingTutorialBoard: View {
    let vm: OrderingViewModel
    let namespace: Namespace.ID

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: ComprehensionLayout.orderingTutorialRowSpacing) {
                ForEach(0..<3, id: \.self) { index in
                    if let card = vm.tutorialCard(forSlot: index) {
                        orderingCard(card)
                    } else {
                        OrderingTutorialSlot(number: index + 1)
                    }
                }
            }

            VStack(spacing: ComprehensionLayout.orderingTutorialRowSpacing) {
                ForEach(vm.tutorialPool) { card in
                    orderingCard(card)
                }
            }
            .padding(.top, ComprehensionLayout.orderingTutorialPoolTopGap)
        }
        .frame(maxWidth: .infinity)
    }

    private func orderingCard(_ card: ComprehensionTutorial.OrderingCard) -> some View {
        OrderingTutorialCard(
            card: card,
            showsHand: vm.tutorialHandTarget == card.id
        )
        .matchedGeometryEffect(id: card.id, in: namespace)
        .zIndex(vm.tutorialHandTarget == card.id ? 1 : 0)
    }
}

private struct OrderingTutorialSlot: View {
    let number: Int

    var body: some View {
        HStack {
            Text(number, format: .number)
                .echoFont(.body, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .frame(width: 34, height: 34)
                .background(ComprehensionColor.slotBadge, in: Circle())
            Spacer(minLength: 0)
        }
        .padding(.leading, 10)
        .frame(maxWidth: .infinity, minHeight: ComprehensionLayout.orderingRowHeight)
        .background(ComprehensionColor.slotFill, in: .rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(ComprehensionColor.slotStroke, style: StrokeStyle(lineWidth: 1.2, dash: [5, 4]))
        )
        .accessibilityLabel("Place \(number), empty")
    }
}

private struct OrderingTutorialCard: View {
    let card: ComprehensionTutorial.OrderingCard
    let showsHand: Bool

    @ViewBuilder
    private var artwork: some View {
        switch card.artwork {
        case .water:
            Text("💧")
                .font(.system(size: 32))
        case .seed:
            Image("img_tutorial-plant-seed")
                .resizable()
                .scaledToFit()
                .padding(6)
        case .flower:
            Text("🌻")
                .font(.system(size: 32))
        }
    }

    private var thumbnailFill: Color {
        switch card.artwork {
        case .water: ComprehensionColor.tutorialWaterThumb
        case .seed: ComprehensionColor.tutorialSeedThumb
        case .flower: ComprehensionColor.tutorialFlowerThumb
        }
    }

    var body: some View {
        HStack(spacing: 13) {
            artwork
                .frame(width: 48, height: 48)
                .background(thumbnailFill, in: .rect(cornerRadius: 13))
                .accessibilityHidden(true)

            Text(card.title)
                .echoFont(.supporting, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Spacer(minLength: 0)
            TutorialDragHandle()
        }
        .padding(.leading, 10)
        .padding(.trailing, 17)
        .frame(maxWidth: .infinity, minHeight: ComprehensionLayout.orderingRowHeight)
        .background(ComprehensionColor.cardFill, in: .rect(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(ComprehensionColor.cardStroke, lineWidth: 1))
        .overlay(alignment: .topLeading) {
            if showsHand {
                ComprehensionTutorialHand()
                    .offset(x: 12, y: 33)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct TutorialDragHandle: View {
    var body: some View {
        VStack(spacing: 2.5) {
            ForEach(0..<3, id: \.self) { _ in
                Capsule()
                    .fill(ComprehensionColor.dragHandle)
                    .frame(width: 14, height: 2)
            }
        }
        .accessibilityHidden(true)
    }
}

/// The demo board from Figma Steps 30–41: three fruits on the left, three colours on the
/// right, and one hand that drags a line from each fruit's dot to its colour's dot.
/// Everything is placed from the measured board width, so it fits any iPhone.
private struct ComprehensionMatchingTutorialBoard: View {
    let vm: MatchingViewModel

    @State private var boardWidth: CGFloat = 382

    private typealias Layout = ComprehensionLayout
    private let pairs = ComprehensionTutorial.matchingPairs
    private let colors = ComprehensionTutorial.matchingColors

    private var tileWidth: CGFloat { Layout.matchingTutorialTileWidth }
    private var tileHeight: CGFloat { Layout.matchingTutorialTileHeight }
    private var rowStep: CGFloat { tileHeight + Layout.matchingTutorialRowSpacing }
    private var boardHeight: CGFloat { tileHeight * 3 + Layout.matchingTutorialRowSpacing * 2 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(pairs.indices, id: \.self) { row in
                MatchingTutorialTile(
                    title: pairs[row].fruit,
                    artwork: pairs[row].fruitArtwork,
                    isActive: vm.tutorialItemIsActive(pairs[row].id)
                )
                .position(x: tileWidth / 2, y: rowCenterY(row))

                MatchingTutorialTile(
                    title: colors[row].title,
                    artwork: colors[row].artwork,
                    isActive: vm.tutorialItemIsActive(colors[row].id)
                )
                .position(x: boardWidth - tileWidth / 2, y: rowCenterY(row))
            }

            ForEach(pairs.indices, id: \.self) { index in
                TutorialLine(start: leftDot(index), end: rightDot(colorRow(pairs[index].colorId)))
                    .trim(from: 0, to: vm.tutorialLineProgress(forPair: index))
                    .stroke(
                        vm.tutorialIsChecked ? ComprehensionColor.matchCorrect : ComprehensionColor.matchLine,
                        style: StrokeStyle(lineWidth: Layout.matchingTutorialLineWidth, lineCap: .round)
                    )
            }

            ForEach(pairs.indices, id: \.self) { row in
                MatchingTutorialDot(style: dotStyle(for: pairs[row].id))
                    .position(leftDot(row))
                MatchingTutorialDot(style: dotStyle(for: colors[row].id))
                    .position(rightDot(row))
            }

            Image("img_tutorial-hand")
                .resizable()
                .frame(width: Layout.matchingTutorialHandSize.width, height: Layout.matchingTutorialHandSize.height)
                .shadow(color: ComprehensionColor.tutorialHandShadow, radius: 2.5, x: 0, y: 3)
                .scaleEffect(vm.tutorialHandIsPressing ? 0.92 : 1, anchor: handTipAnchor)
                .position(handCenter)
                .opacity(vm.tutorialShowsHand ? 1 : 0)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: boardHeight, alignment: .topLeading)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { boardWidth = $0 }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Example: drag a line from each fruit to its colour. Banana to Yellow, Apple to Red, Grapes to Purple.")
    }

    // MARK: - Geometry (measured from the board's top-left corner)

    private func rowCenterY(_ row: Int) -> CGFloat {
        tileHeight / 2 + rowStep * CGFloat(row)
    }

    private func leftDot(_ row: Int) -> CGPoint {
        CGPoint(x: tileWidth, y: rowCenterY(row))
    }

    private func rightDot(_ row: Int) -> CGPoint {
        CGPoint(x: boardWidth - tileWidth, y: rowCenterY(row))
    }

    private func colorRow(_ id: String) -> Int {
        colors.firstIndex { $0.id == id } ?? 0
    }

    /// Where the fingertip points. The finger always travels in a straight line from a fruit's
    /// dot to its colour's dot, with the same curve as the line, so the line grows right
    /// under the fingertip.
    private var fingertip: CGPoint {
        switch vm.tutorialHandSpot {
        case .offscreen:
            return CGPoint(x: tileWidth, y: boardHeight + Layout.matchingTutorialHandStartDrop)
        case .fruitDot(let pair):
            return leftDot(pair)
        case .colorDot(let pair):
            return rightDot(colorRow(pairs[pair].colorId))
        case .liftedFromColorDot(let pair):
            let dot = rightDot(colorRow(pairs[pair].colorId))
            return CGPoint(x: dot.x + 10, y: dot.y + 22)
        }
    }

    private var handTipAnchor: UnitPoint {
        let size = Layout.matchingTutorialHandSize
        let tip = Layout.matchingTutorialHandTip
        return UnitPoint(x: tip.x / size.width, y: tip.y / size.height)
    }

    private var handCenter: CGPoint {
        let size = Layout.matchingTutorialHandSize
        let tip = Layout.matchingTutorialHandTip
        return CGPoint(x: fingertip.x + size.width / 2 - tip.x, y: fingertip.y + size.height / 2 - tip.y)
    }

    private func dotStyle(for id: String) -> MatchingTutorialDot.Style {
        if vm.tutorialIsChecked { return .checked }
        return vm.tutorialItemIsActive(id) ? .active : .idle
    }
}

/// A straight line between two dots. `trim` draws it growing from the fruit's dot.
private struct TutorialLine: Shape {
    let start: CGPoint
    let end: CGPoint

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
    }
}

/// The 22 pt connector dot on a card's inner edge.
private struct MatchingTutorialDot: View {
    enum Style {
        case idle
        case active
        case checked
    }

    let style: Style

    private var fill: Color {
        switch style {
        case .idle: ComprehensionColor.matchDotIdleFill
        case .active: ComprehensionColor.matchLine
        case .checked: ComprehensionColor.matchCorrect
        }
    }

    private var ring: Color {
        style == .idle ? ComprehensionColor.matchDotIdleStroke : .white
    }

    var body: some View {
        Circle()
            .fill(fill)
            .strokeBorder(ring, lineWidth: ComprehensionLayout.matchingDotStroke)
            .frame(width: ComprehensionLayout.matchingTutorialDotSize, height: ComprehensionLayout.matchingTutorialDotSize)
    }
}

/// A 140 × 114 card: artwork 14 pt from the top, label 9 pt from the bottom.
private struct MatchingTutorialTile: View {
    let title: String
    let artwork: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 0) {
            Image(artwork)
                .resizable()
                .scaledToFit()
                .frame(
                    width: ComprehensionLayout.matchingTutorialArtworkSize,
                    height: ComprehensionLayout.matchingTutorialArtworkSize
                )
                .padding(.top, ComprehensionLayout.matchingTutorialArtworkTop)
            Spacer(minLength: 0)
            Text(title)
                .echoFont(.supporting, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .lineLimit(1)
                .padding(.bottom, ComprehensionLayout.matchingTutorialLabelBottom)
        }
        .frame(width: ComprehensionLayout.matchingTutorialTileWidth, height: ComprehensionLayout.matchingTutorialTileHeight)
        .background(ComprehensionColor.tileFill, in: .rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    isActive ? ComprehensionColor.matchTileHighlight : ComprehensionColor.tileStroke,
                    lineWidth: isActive ? ComprehensionLayout.matchingHighlightStroke : 1
                )
        )
        .echoShadow(ComprehensionColor.frostedCardShadow)
    }
}

/// The pointing hand in the Ordering demo: the same artwork as the Matching demo,
/// large enough to see clearly on the cards.
private struct ComprehensionTutorialHand: View {
    var body: some View {
        Image("img_tutorial-hand")
            .resizable()
            .frame(width: 76, height: 84)
            .shadow(color: ComprehensionColor.tutorialHandShadow, radius: 2.5, x: 0, y: 3)
            .accessibilityHidden(true)
    }
}
