import Foundation
import Observation

@Observable
@MainActor
final class SpeakingProgressViewModel {
    private(set) var state: ProgressLoadState<SpeakingProgressReport> = .loading

    private let service: any ProgressReportService
    private let router: AppRouter

    init(service: any ProgressReportService, router: AppRouter) {
        self.service = service
        self.router = router
    }

    // MARK: - Shown on screen

    var chipText: String {
        guard let level = state.value?.level else { return "" }
        return "Level \(level.number) of \(level.total)"
    }

    /// The day with the most new words, highlighted in the chart.
    var bestDayId: Int? {
        state.value?.dailyWords.filter { $0.value != nil }.max { ($0.value ?? 0) < ($1.value ?? 0) }?.id
    }

    // MARK: - User actions

    func load() async {
        if state.value != nil { return }
        await fetch()
    }

    func didTapRetry() async {
        state = .loading
        await fetch()
    }

    // MARK: - Private

    private func fetch() async {
        do {
            state = .loaded(try await service.speaking())
        } catch {
            state = .failed("We couldn’t load speaking progress right now.")
        }
    }
}
