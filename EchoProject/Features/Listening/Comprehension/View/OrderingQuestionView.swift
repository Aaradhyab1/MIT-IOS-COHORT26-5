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

                VStack(spacing: EchoSpacing.m) {
                    ForEach(vm.slots) { slot in
                        Button { vm.didTapSlot(slot) } label: {
                            OrderingSlotView(slot: slot, mark: vm.mark(for: slot))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 23)
                .padding(.top, 38)

                if !vm.pool.isEmpty {
                    VStack(spacing: EchoSpacing.m) {
                        ForEach(vm.pool) { card in
                            Button { vm.didTapPoolCard(card) } label: {
                                OrderingCardView(card: card)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 23)
                    .padding(.top, 36)
                }
            }
            .padding(.horizontal, EchoSpacing.screenHorizontal)
            .padding(.top, ComprehensionLayout.questionTop)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            bottomButton
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

private struct OrderingSlotView: View {
    let slot: OrderingViewModel.Slot
    let mark: OrderingViewModel.Mark?

    var body: some View {
        if let card = slot.card {
            OrderingCardView(card: card, mark: mark)
                .accessibilityLabel("\(slot.number). \(card.text)")
        } else {
            HStack {
                Text(slot.number, format: .number)
                    .echoFont(.body, .semibold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .frame(width: 34, height: 34)
                    .background(ComprehensionColor.slotBadge, in: Circle())
                Spacer()
            }
            .padding(.leading, 10)
            .frame(maxWidth: .infinity, minHeight: ComprehensionLayout.orderingRowHeight)
            .background(ComprehensionColor.slotFill, in: .rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(ComprehensionColor.slotStroke, style: StrokeStyle(lineWidth: 1.2, dash: [5, 4]))
            )
            .accessibilityLabel("Place \(slot.number), empty")
        }
    }
}

private struct OrderingCardView: View {
    let card: OrderingViewModel.Card
    var mark: OrderingViewModel.Mark? = nil

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
