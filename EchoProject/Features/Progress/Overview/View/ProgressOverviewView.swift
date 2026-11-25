import SwiftUI

/// Progress tab: streak, sessions and learning paths.
/// Figma: Precoding_FINAL › Progress_v2 · Revamp › 01 · Overview.
struct ProgressOverviewView: View {
    @State private var vm: ProgressOverviewViewModel

    init(vm: ProgressOverviewViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ProgressStateView(state: vm.state, retry: vm.didTapRetry) { report in
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    WeekStreakCard(week: report.week, streakText: vm.streakText, sessionsText: vm.sessionsText)

                    VStack(alignment: .leading, spacing: 12) {
                        ProgressSectionHeader(title: "Learning paths")
                        ForEach(report.paths) { path in
                            Button {
                                vm.didTapPath(path.track)
                            } label: {
                                LearningPathCard(
                                    path: path,
                                    levelLine: vm.levelLine(for: path),
                                    completedLine: vm.completedLine(for: path)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .background(ProgressPalette.background.ignoresSafeArea())
        .navigationTitle("Progress")
        .task { await vm.load() }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        ProgressOverviewView(vm: container.makeProgressOverviewViewModel())
    }
    .environment(container)
    .environment(container.router)
}
