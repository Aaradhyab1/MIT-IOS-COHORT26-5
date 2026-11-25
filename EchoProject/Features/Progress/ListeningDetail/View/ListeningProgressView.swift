import SwiftUI

/// Figma: Precoding_FINAL › Progress_v2 · Revamp › 02 · Listening.
struct ListeningProgressView: View {
    @State private var vm: ListeningProgressViewModel

    init(vm: ListeningProgressViewModel) {
        _vm = State(initialValue: vm)
    }

    private let tint = ProgressPalette.tint(.listening)

    var body: some View {
        ProgressStateView(state: vm.state, retry: vm.didTapRetry) { report in
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text(report.subtitle)
                        .font(.body)
                        .foregroundStyle(ProgressPalette.textSecondary)
                        .padding(.horizontal, 4)
                        .padding(.bottom, -12)

                    LevelHeroCard(track: .listening, level: report.level, chipText: vm.chipText)

                    AccuracyChartCard(
                        weeklyAccuracy: report.weeklyAccuracy,
                        change: report.accuracyChange,
                        days: report.dailyAccuracy,
                        latestDayId: vm.latestDayId
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        ProgressSectionHeader(title: "Skills in this level",
                                              hint: "Where they shine, and where they’re still growing")
                        SkillsCard(skills: report.skills, tint: tint)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        ProgressSectionHeader(title: "The listening path")
                        PathTimelineCard(steps: report.path, tint: tint)
                    }

                    Text(report.footnote)
                        .font(.subheadline)
                        .foregroundStyle(ProgressPalette.textSecondary)
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(ProgressPalette.background.ignoresSafeArea())
        .navigationTitle(ProgressTrack.listening.title)
        .task { await vm.load() }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        ListeningProgressView(vm: container.makeListeningProgressViewModel())
    }
    .environment(container)
    .environment(container.router)
}
