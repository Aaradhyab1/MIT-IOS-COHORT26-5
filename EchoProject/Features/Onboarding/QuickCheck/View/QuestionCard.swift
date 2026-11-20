import SwiftUI

/// One Quick Check question: "Question n of 8", the question, a hint or Ling-sound chips,
/// and the Often / Sometimes / Never segmented control.
struct QuestionCard: View {
    @Bindable var vm: QuickCheckViewModel
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
                .padding(.top, EchoSpacing.l)

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

            Spacer(minLength: EchoSpacing.xl)

            Picker("Answer", selection: $vm.currentAnswer) {
                ForEach(QuickCheckAnswer.allCases, id: \.self) { answer in
                    Text(vm.label(for: answer))
                        .tag(QuickCheckAnswer?.some(answer))
                }
            }
            .pickerStyle(.segmented)
            .controlSize(.large)
        }
        .padding(23)
        .frame(maxWidth: .infinity, minHeight: 278, alignment: .topLeading)
        .echoCard(cornerRadius: 28)
    }
}
