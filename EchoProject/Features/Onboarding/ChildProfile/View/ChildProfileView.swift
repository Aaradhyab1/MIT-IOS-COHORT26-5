import SwiftUI

/// "About your child": Leo on the grass, two optional date fields, Continue and Skip.
/// Figma: Precoding_FINAL › 02 · Onboarding › "Onboarding / Child profile — optional".
struct ChildProfileView: View {
    @State private var vm: ChildProfileViewModel

    init(vm: ChildProfileViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // One exported picture: Leo with his cupcake, standing on the grass mound.
                // Figma: "Art · Leo · Birthday cupcake" (226 × 154 pt including the grass).
                EchoAssetImage(name: "img_leo_cupcake")
                    .blendMode(.multiply)   // Leo's white backdrop disappears on the light screen, as in Figma
                    .frame(width: 226, height: 154)
                    .padding(.top, 95)

                Text("About your child")
                    .echoFont(.heading, .bold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 7)

                Text("These dates help us pick the right practice.")
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.textSecondary)
                    .padding(.top, EchoSpacing.xs)

                form
                    .padding(.top, 33)
                    .padding(.horizontal, 13)   // card is 336 pt wide on a 402 pt screen
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, EchoSpacing.screenHorizontal)
            .padding(.bottom, EchoSpacing.xl)
        }
        .scrollBounceBehavior(.basedOnSize)
        .echoScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()   // no swiping back to the splash
        .sheet(item: $vm.editingField) { _ in
            calendarSheet
        }
    }

    // MARK: - Card

    private var form: some View {
        VStack(spacing: 18.5) {
            DateFieldRow(title: "Date of birth", value: vm.text(for: .dateOfBirth)) {
                vm.didTapField(.dateOfBirth)
            }
            DateFieldRow(title: "Aid or implant activation date", value: vm.text(for: .activationDate)) {
                vm.didTapField(.activationDate)
            }

            Button("Continue", action: vm.didTapContinue)
                .buttonStyle(.echoPrimary)

            Button(action: vm.didTapSkip) {
                Text("Skip for now")
                    .echoFont(.body)
                    .foregroundStyle(EchoColor.accent)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.plain)
            .padding(.top, -12)   // Skip sits 6.5 pt under Continue in Figma
        }
        .padding(.horizontal, 23.5)
        .padding(.top, 21.5)
        .padding(.bottom, 20)
        .echoCard()
    }

    // MARK: - Calendar

    private var calendarSheet: some View {
        NavigationStack {
            DatePicker(vm.editingTitle, selection: $vm.draftDate, in: vm.draftRange, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding(.horizontal, EchoSpacing.l)
                .navigationTitle(vm.editingTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Clear", action: vm.didClearDate)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", action: vm.didConfirmDate)
                    }
                }
        }
        .presentationDetents([.height(480)])
    }
}

/// One date field: label with a calendar icon, the date (or "mm/dd/yyyy"), and a hairline.
/// Tapping anywhere on it opens the calendar.
private struct DateFieldRow: View {
    let title: String
    /// Nil while no date is chosen.
    let value: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: EchoSpacing.xs) {
                HStack(spacing: 6) {
                    Text(title)
                        .echoFont(.supporting, .semibold)
                        .foregroundStyle(EchoColor.textPrimary)
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundStyle(EchoColor.accent)
                }
                Text(value ?? "mm/dd/yyyy")
                    .echoFont(.body)
                    .foregroundStyle(value == nil ? EchoColor.fieldPlaceholder : EchoColor.textPrimary)
                    .frame(height: 27)
                Rectangle()
                    .fill(EchoColor.fieldUnderline)
                    .frame(height: 0.8)
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value ?? "Not set")
        .accessibilityHint("Opens a calendar")
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: false)
    return NavigationStack {
        ChildProfileView(vm: container.makeChildProfileViewModel())
    }
    .environment(container)
    .environment(container.router)
}
