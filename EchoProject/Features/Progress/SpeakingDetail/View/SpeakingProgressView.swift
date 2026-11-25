import SwiftUI

/// Figma: Precoding_FINAL › Progress_v2 · Revamp › 03 · Speaking.
struct SpeakingProgressView: View {
    @State private var vm: SpeakingProgressViewModel

    init(vm: SpeakingProgressViewModel) {
        _vm = State(initialValue: vm)
    }

    private let tint = ProgressPalette.tint(.speaking)

    var body: some View {
        ProgressStateView(state: vm.state, retry: vm.didTapRetry) { report in
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text(report.subtitle)
                        .font(.body)
                        .foregroundStyle(ProgressPalette.textSecondary)
                        .padding(.horizontal, 4)
                        .padding(.bottom, -12)

                    LevelHeroCard(track: .speaking, level: report.level, chipText: vm.chipText)

                    NewWordsCard(
                        total: report.newWordsThisWeek,
                        days: report.dailyWords,
                        examples: report.wordExamples,
                        bestDayId: vm.bestDayId
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        ProgressSectionHeader(title: "Speech moments",
                                              hint: "Everyday wins show how words are growing")
                        SpeechMomentsCard(moments: report.moments)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        ProgressSectionHeader(title: "The speaking path")
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
        .navigationTitle(ProgressTrack.speaking.title)
        .task { await vm.load() }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        SpeakingProgressView(vm: container.makeSpeakingProgressViewModel())
    }
    .environment(container)
    .environment(container.router)
}
