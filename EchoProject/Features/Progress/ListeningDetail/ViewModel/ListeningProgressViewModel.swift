import Foundation
import Observation

@Observable
@MainActor
final class ListeningProgressViewModel {
    private(set) var state: ProgressLoadState<ListeningProgressReport> = .loading

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

    /// The last day with a score, which the chart labels with a callout.
    var latestDayId: Int? {
        state.value?.dailyAccuracy.last { $0.value != nil }?.id
    }

    var accuracyIsUp: Bool {
        (state.value?.accuracyChange ?? 0) >= 0
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
            state = .loaded(try await service.listening())
        } catch {
            state = .failed("We couldn’t load listening progress right now.")
        }
    }
}
