import SwiftUI

/// Exercise list for one level (PRECODING: "Differentiation / Exercise library").
/// A heading, then a List with one Section per collection, each row an exercise card
/// with artwork, title and a "0 / 10" progress bar.
struct LevelLibraryView: View {
    @State private var vm: LevelLibraryViewModel

    init(vm: LevelLibraryViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        content
            .echoScreenBackground()
            .onAppear { vm.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .loading:
            ProgressView()
        case .error(let message):
            Text(message)
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.textSecondary)
        case .ready(let title, let sections):
            List {
                Text(title)
                    .echoFont(.heading, .bold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .libraryRow()

                ForEach(sections) { section in
                    Section {
                        ForEach(section.rows) { row in
                            LevelLibraryRow(row: row) { vm.didTap(row) }
                                .libraryRow()
                        }
                    } header: {
                        if let sectionTitle = section.title {
                            EchoSectionHeader(title: sectionTitle)
                                .textCase(nil)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

/// One exercise card in the library list. Lives in this folder because the shared
/// `EchoExerciseCard` is the 160 pt carousel card, not this full-width row.
private struct LevelLibraryRow: View {
    let row: LevelLibraryViewModel.Row
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: EchoSpacing.s) {
                EchoArtwork(imageName: row.illustration, cornerRadius: EchoRadius.thumbnailSmall)
                    .frame(width: 100, height: 100)

                VStack(alignment: .leading, spacing: 6) {
                    Text(row.title)
                        .echoFont(.body, .semibold)
                        .foregroundStyle(EchoColor.textPrimary)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: EchoSpacing.s) {
                        ProgressView(value: row.fraction)
                            .tint(EchoColor.accent)
                        Text(row.countText)
                            .echoFont(.caption)
                            .foregroundStyle(EchoColor.textSecondary)
                            .monospacedDigit()
                    }
                }

                Image(systemName: "chevron.right")
                    .echoFont(.caption, .semibold)
                    .foregroundStyle(EchoColor.textSecondary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, EchoSpacing.m)
            .padding(.vertical, EchoSpacing.s)
            .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
            .echoCard(cornerRadius: EchoRadius.cardLarge)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(row.title)
        .accessibilityValue(row.accessibilityProgress)
    }
}

private extension View {
    /// Removes the List's default row look so each card floats on the screen background.
    func libraryRow() -> some View {
        listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(
                top: EchoSpacing.s / 2,
                leading: EchoSpacing.screenHorizontal,
                bottom: EchoSpacing.s / 2,
                trailing: EchoSpacing.screenHorizontal
            ))
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        LevelLibraryView(vm: container.makeLevelLibraryViewModel(levelId: "listening.differentiation"))
    }
    .environment(container)
    .environment(container.router)
}
