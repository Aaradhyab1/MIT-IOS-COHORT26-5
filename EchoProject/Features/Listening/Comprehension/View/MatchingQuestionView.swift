import SwiftUI

struct MatchingQuestionView: View {
    let vm: MatchingViewModel

    private var subtitleColor: Color {
        switch vm.state {
        case .answering, .incorrect: EchoColor.textSecondary
        case .correct: ComprehensionColor.correct
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                QuestionHeader(title: vm.prompt, subtitle: vm.subtitle, subtitleColor: subtitleColor)

                VStack(spacing: EchoSpacing.xl) {
                    ForEach(vm.rows) { row in
                        HStack(spacing: 51) {
                            Button { vm.didTapLeft(row.left) } label: {
                                MatchingTileView(tile: row.left, isSelected: vm.isSelected(row.left))
                            }
                            .buttonStyle(.plain)

                            Button { vm.didTapRight(row.right) } label: {
                                MatchingTileView(tile: row.right, isSelected: false)
                            }
                            .buttonStyle(.plain)
                        }
                        .overlay {
                            HStack(spacing: 24) {
                                ConnectorDot(number: vm.pairNumber(forLeft: row.left), mark: vm.mark(forLeft: row.left))
                                ConnectorDot(number: vm.pairNumber(forRight: row.right), mark: vm.mark(forRight: row.right))
                            }
                            .allowsHitTesting(false)
                        }
                    }
                }
                .padding(.top, 13)
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
            ComprehensionBottomButton(title: "Check answer", isEnabled: vm.canCheck, action: vm.didTapCheck)
        case .correct:
            ComprehensionBottomButton(title: "Continue", action: vm.didTapContinue)
        case .incorrect:
            ComprehensionBottomButton(title: "Try again", action: vm.didTapTryAgain)
        }
    }
}

private struct MatchingTileView: View {
    let tile: MatchingViewModel.Tile
    let isSelected: Bool

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
                .stroke(isSelected ? EchoColor.accent : ComprehensionColor.tileStroke, lineWidth: isSelected ? 3 : 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct ConnectorDot: View {
    let number: Int?
    let mark: MatchingViewModel.Mark?

    private var color: Color {
        switch mark {
        case .correct: ComprehensionColor.correct
        case .incorrect: ComprehensionColor.incorrect
        case nil: EchoColor.accentFill
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(number == nil ? Color.white.opacity(0.8) : color)
            Circle()
                .stroke(color, lineWidth: 3)
            if let number {
                Text(number, format: .number)
                    .echoFont(.caption, .bold)
                    .foregroundStyle(EchoColor.textOnAccent)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(width: 19, height: 19)
        .accessibilityHidden(true)
    }
}

#Preview("Matching") {
    let question = ExerciseItem(
        id: "preview.matching",
        prompt: "Who did what?",
        text: "Match each character to what they did.",
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
