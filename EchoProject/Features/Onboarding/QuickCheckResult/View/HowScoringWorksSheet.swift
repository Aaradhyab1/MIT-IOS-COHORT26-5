import SwiftUI

/// "How scoring works": what each answer is worth, and which questions decide each level.
/// Figma: "Level completion · How scoring works open". Shown as a bottom sheet.
struct HowScoringWorksSheet: View {
    let answerValueRows: [ScoringRow]
    let placementRows: [ScoringRow]
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: EchoSpacing.s) {
                    Text("How scoring works")
                        .echoFont(.heading, .bold)
                        .foregroundStyle(EchoColor.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text("Each answer earns points. The total shows where your child should start.")
                        .echoFont(.supporting)
                        .foregroundStyle(EchoColor.textSecondary)
                }
                Spacer(minLength: EchoSpacing.s)
                Button("Close", systemImage: "xmark", action: onClose)
                    .labelStyle(.iconOnly)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(EchoColor.textSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                    .padding(.top, -8)
                    .padding(.trailing, -10)
            }

            Text("Answer values")
                .echoFont(.supporting, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 20)
            ScoringRowList(rows: answerValueRows, emphasis: .value)
                .padding(.top, EchoSpacing.xs)

            Text("How placement is determined")
                .echoFont(.supporting, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, 24)
            ScoringRowList(rows: placementRows, emphasis: .label)
                .padding(.top, EchoSpacing.xs)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 23)
        .padding(.top, 28)
    }
}
