import SwiftUI

/// One Quick Check question: "Question n of 8", the question, a hint or Ling-sound chips,
/// and the three answer buttons.
///
/// Every card uses the same spacing (12 after the label, 8 under the question, 24 above
/// the answers) and is as tall as its content, so short questions don't leave a gap.
struct QuestionCard: View {
    let vm: QuickCheckViewModel
    let question: QuickCheckQuestion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(vm.questionNumberText)
                .echoFont(.caption, .semibold)
                .foregroundStyle(EchoColor.accent)

            Text(question.text)
                .echoFont(.heading, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, EchoSpacing.m)

            if let hint = question.hint {
                Text(hint)
                    .echoFont(.body)
                    .foregroundStyle(EchoColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, EchoSpacing.s)
            }

            if let choices = question.choices {
                LingSoundChips(choices: choices, isSelected: vm.isChoiceSelected, onToggle: vm.didToggleChoice)
                    .padding(.top, EchoSpacing.l)
            }

            AnswerOptions(
                options: QuickCheckAnswer.allCases,
                selected: vm.currentAnswer,
                label: vm.label(for:),
                onSelect: vm.didSelect
            )
            .padding(.top, 24)
        }
        .padding(23)
        .frame(maxWidth: .infinity, alignment: .leading)
        .echoCard(cornerRadius: 28)
    }
}
