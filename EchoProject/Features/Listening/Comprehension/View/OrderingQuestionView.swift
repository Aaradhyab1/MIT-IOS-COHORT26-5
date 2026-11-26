import SwiftUI

struct OrderingQuestionView: View {
    let vm: OrderingViewModel

    private var titleColor: Color {
        switch vm.state {
        case .answering: EchoColor.textPrimary
        case .correct: ComprehensionColor.correct
        case .incorrect: ComprehensionColor.incorrect
        }
    }

    var body: some View {
        Group {
            if vm.isShowingTutorial {
                ComprehensionOrderingTutorialView(vm: vm)
            } else {
                questionContent
            }
        }
    }

    private var questionContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                QuestionHeader(
                    title: vm.title,
                    subtitle: vm.subtitle,
                    onHowToPlay: vm.didTapHowToPlay,
                    titleColor: titleColor
                )

                OrderingBoard(vm: vm)
                    .padding(.horizontal, 23)
                    .padding(.top, 38)
            }
            .padding(.horizontal, EchoSpacing.screenHorizontal)
            .padding(.top, ComprehensionLayout.questionTop)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDisabled(vm.isDragging)
        .safeAreaInset(edge: .bottom) {
            bottomButton
        }
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
            if vm.canCheck {
                ComprehensionBottomButton(title: "Check answer", action: vm.didTapCheck)
            }
        case .correct:
            ComprehensionBottomButton(title: "Continue", action: vm.didTapContinue)
        case .incorrect:
            ComprehensionBottomButton(title: "Try again", action: vm.didTapTryAgain)
        }
    }
}

/// The numbered places and the pile of cards.
///
/// The places and the pile only reserve space (and report where each spot is). Every card
/// is drawn once, on a layer above them, at the spot it belongs to. Moving a card between
/// the pile and a place, or swapping two cards, just changes which spot it is drawn at,
/// so it always glides there in one smooth motion instead of disappearing and reappearing.
/// Each card keeps its own home in the pile, so nothing else shuffles while a child plays.
private struct OrderingBoard: View {
    let vm: OrderingViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var spotFrames: [Spot: CGRect] = [:]
    @State private var dragOffset: CGSize = .zero
    /// Resets to false by itself when a drag ends or the system cancels it.
    @GestureState private var isPressing = false

    private enum Spot: Hashable {
        case place(Int)
        case home(String)
    }

    private static let space = "orderingBoard"
    private typealias Card = OrderingViewModel.Card

    private var glide: Animation? {
        reduceMotion ? nil : .spring(duration: 0.38, bounce: 0.18)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: EchoSpacing.m) {
                ForEach(vm.slots) { slot in
                    ZStack {
                        OrderingSlotView(number: slot.number, isTargeted: vm.isDropTarget(slot))
                        if let card = slot.card {
                            OrderingCardView(card: card).hidden()
                        }
                    }
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(Self.space)) } action: {
                        record($0, for: .place(slot.number))
                    }
                }
            }

            VStack(spacing: EchoSpacing.m) {
                ForEach(vm.pile) { card in
                    OrderingCardView(card: card)
                        .hidden()
                        .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(Self.space)) } action: {
                            record($0, for: .home(card.id))
                        }
                }
            }
            .padding(.top, 36)
        }
        .overlay(alignment: .topLeading) {
            ForEach(vm.pile) { card in
                if let frame = frame(of: card) {
                    draggableCard(card, at: frame)
                }
            }
        }
        .coordinateSpace(.named(Self.space))
        .animation(.easeOut(duration: 0.15), value: vm.dropTarget)
        .sensoryFeedback(.selection, trigger: vm.dropTarget) { _, newTarget in newTarget != nil }
        .sensoryFeedback(.impact(weight: .medium), trigger: vm.placementRevision)
        .onChange(of: isPressing) { _, pressing in
            guard !pressing else { return }
            // A normal lift also ends the press, so wait one beat: only a drag that never
            // reached onEnded (cancelled by the system) is still active here.
            Task { @MainActor in
                guard vm.isDragging else { return }
                withAnimation(glide) {
                    vm.didCancelDrag()
                    dragOffset = .zero
                }
            }
        }
    }

    // MARK: - Where each card is drawn

    private func placeNumber(of card: Card) -> Int? {
        vm.slots.first { $0.card?.id == card.id }?.number
    }

    private func frame(of card: Card) -> CGRect? {
        if let number = placeNumber(of: card) {
            return spotFrames[.place(number)]
        }
        return spotFrames[.home(card.id)]
    }

    /// Spots that move (for example, a longer card making a place taller) glide too.
    private func record(_ frame: CGRect, for spot: Spot) {
        guard spotFrames[spot] != frame else { return }
        if spotFrames[spot] == nil {
            spotFrames[spot] = frame
        } else {
            withAnimation(glide) { spotFrames[spot] = frame }
        }
    }

    // MARK: - Cards

    private func draggableCard(_ card: Card, at frame: CGRect) -> some View {
        let isDragged = vm.isDragging(card)
        let place = placeNumber(of: card)
        let mark = place.flatMap { number in vm.slots.first { $0.number == number } }.flatMap(vm.mark(for:))
        return OrderingCardView(card: card, mark: mark, isLifted: isDragged)
            .frame(width: frame.width, height: frame.height)
            .offset(
                x: frame.minX + (isDragged ? dragOffset.width : 0),
                y: frame.minY + (isDragged ? dragOffset.height : 0)
            )
            .zIndex(isDragged ? 2 : (place == nil ? 0 : 1))
            .highPriorityGesture(dragGesture(for: card), including: vm.state == .answering ? .all : .subviews)
            .onTapGesture {
                if place == nil { sendToNextEmptyPlace(card) }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(place.map { "\($0). \(card.text)" } ?? card.text)
            .accessibilityHint(vm.state == .answering ? "Drag to a numbered place, or tap to fill the next one" : "")
            .accessibilityActions {
                if vm.state == .answering {
                    ForEach(vm.slots.filter { $0.number != place }) { target in
                        Button("Move to place \(target.number)") {
                            withAnimation(glide) { vm.place(card, inSlot: target.number) }
                        }
                    }
                    if place != nil {
                        Button("Take out") {
                            withAnimation(glide) { vm.returnToPool(card) }
                        }
                    }
                }
            }
    }

    // MARK: - Dragging

    private func dragGesture(for card: Card) -> some Gesture {
        DragGesture(minimumDistance: 3, coordinateSpace: .named(Self.space))
            .updating($isPressing) { _, pressing, _ in pressing = true }
            .onChanged { value in
                if !vm.isDragging {
                    vm.didBeginDragging(card)
                }
                guard vm.isDragging(card) else { return }
                dragOffset = value.translation
                vm.didMoveDrag(over: dropTarget(for: card, moved: value.translation))
            }
            .onEnded { _ in
                guard vm.isDragging(card) else { return }
                land()
            }
    }

    /// The card's spot changes and its drag offset returns to zero in the same spring, so it
    /// flies straight from under the finger to where it now belongs (or back home).
    private func land() {
        withAnimation(glide) {
            vm.didEndDrag()
            dragOffset = .zero
        }
    }

    /// Forgiving for small hands: anywhere over the numbered places counts, and the card goes
    /// to whichever place its centre is closest to. Below the places, a placed card can be
    /// dropped back home in the pile.
    private func dropTarget(for card: Card, moved offset: CGSize) -> OrderingViewModel.DropTarget? {
        guard let frame = frame(of: card) else { return nil }
        let places = vm.slots.compactMap { slot in spotFrames[.place(slot.number)].map { (slot.number, $0) } }
        guard let top = places.map(\.1.minY).min(), let bottom = places.map(\.1.maxY).max() else { return nil }

        let center = CGPoint(x: frame.midX + offset.width, y: frame.midY + offset.height)
        let reach = ComprehensionLayout.orderingRowHeight * 0.6
        if center.y >= top - reach && center.y <= bottom + reach * 0.5 {
            let nearest = places.min { abs($0.1.midY - center.y) < abs($1.1.midY - center.y) }
            return nearest.map { .slot($0.0) }
        }
        return placeNumber(of: card) != nil && center.y > bottom ? .pool : nil
    }

    /// A tap on a pile card sends it gliding into the next empty place.
    private func sendToNextEmptyPlace(_ card: Card) {
        guard !vm.isDragging, let number = vm.nextEmptySlotNumber else { return }
        withAnimation(glide) { vm.place(card, inSlot: number) }
    }
}

private struct OrderingSlotView: View {
    let number: Int
    let isTargeted: Bool

    var body: some View {
        HStack {
            Text(number, format: .number)
                .echoFont(.body, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .frame(width: 34, height: 34)
                .background(ComprehensionColor.slotBadge, in: Circle())
            Spacer()
        }
        .padding(.leading, 10)
        .frame(maxWidth: .infinity, minHeight: ComprehensionLayout.orderingRowHeight)
        .background(isTargeted ? ComprehensionColor.slotTargetFill : ComprehensionColor.slotFill, in: .rect(cornerRadius: 20))
        .shadow(color: isTargeted ? ComprehensionColor.slotTargetStroke.opacity(0.18) : .clear, radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isTargeted ? ComprehensionColor.slotTargetStroke : ComprehensionColor.slotStroke,
                    style: StrokeStyle(lineWidth: isTargeted ? 1.5 : 1.2, dash: isTargeted ? [] : [5, 4])
                )
        )
        .accessibilityLabel("Place \(number), empty")
    }
}

private struct OrderingCardView: View {
    let card: OrderingViewModel.Card
    var mark: OrderingViewModel.Mark? = nil
    var isLifted = false

    private var fill: Color {
        switch mark {
        case .correct: ComprehensionColor.correctFill
        case .incorrect: ComprehensionColor.incorrectFill
        case nil: ComprehensionColor.cardFill
        }
    }

    private var stroke: Color {
        switch mark {
        case .correct: ComprehensionColor.correct
        case .incorrect: ComprehensionColor.incorrect
        case nil: ComprehensionColor.cardStroke
        }
    }

    var body: some View {
        HStack(spacing: 13) {
            EchoArtwork(imageName: card.image ?? "", cornerRadius: 12)
                .frame(width: 48, height: 48)
            Text(card.text)
                .echoFont(.supporting, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
            DragHandle()
        }
        .padding(.leading, 10)
        .padding(.trailing, 17)
        .frame(maxWidth: .infinity, minHeight: ComprehensionLayout.orderingRowHeight)
        .background(fill, in: .rect(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(stroke, lineWidth: mark == nil ? 1 : 2))
        .contentShape(.rect(cornerRadius: 20))
        .scaleEffect(isLifted ? 1.04 : 1)
        .shadow(color: .black.opacity(isLifted ? 0.16 : 0), radius: 12, y: 8)
        .animation(.spring(duration: 0.3, bounce: 0.2), value: isLifted)
    }
}

private struct DragHandle: View {
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

#Preview("Ordering") {
    let item = ExerciseItem(
        id: "preview.ordering",
        prompt: "Put the events in order",
        text: "Drag each card into the right number.",
        options: [
            Option(id: "1", label: "The bird saw the bread.", image: "img_story-cat-and-bird-event-1"),
            Option(id: "2", label: "The cat chased the bird.", image: "img_story-cat-and-bird-event-2"),
            Option(id: "3", label: "The bird flew away safely.", image: "img_story-cat-and-bird-event-3")
        ]
    )
    return OrderingQuestionView(vm: OrderingViewModel(item: item) { _ in })
        .echoExerciseBackground()
}
