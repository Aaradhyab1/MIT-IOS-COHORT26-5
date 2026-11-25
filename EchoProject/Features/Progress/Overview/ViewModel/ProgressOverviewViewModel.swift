import Foundation
import Observation

@Observable
@MainActor
final class ProgressOverviewViewModel {
    private(set) var state: ProgressLoadState<ProgressOverviewReport> = .loading

    private let service: any ProgressReportService
    private let router: AppRouter

    init(service: any ProgressReportService, router: AppRouter) {
        self.service = service
        self.router = router
    }

    // MARK: - Shown on screen

    var streakText: String {
        guard let week = state.value?.week else { return "" }
        return "\(week.streakDays)-day streak"
    }

    var sessionsText: String {
        guard let week = state.value?.week else { return "" }
        return week.sessions == 1 ? "1 practice session" : "\(week.sessions) practice sessions"
    }

    func levelLine(for path: ProgressPathSummary) -> String {
        "\(path.level.name) · Level \(path.level.number) of \(path.level.total)"
    }

    func completedLine(for path: ProgressPathSummary) -> String {
        "\(path.level.completedLevels) of \(path.level.total) levels complete"
    }

    // MARK: - User actions

    func load() async {
        if state.value != nil { return }
        await fetch()
    }

    func didTapPath(_ track: ProgressTrack) {
        switch track {
        case .listening: router.go(.listeningProgress)
        case .speaking: router.go(.speakingProgress)
        }
    }

    func didTapRetry() async {
        state = .loading
        await fetch()
    }

    // MARK: - Private

    private func fetch() async {
        do {
            state = .loaded(try await service.overview())
        } catch {
            state = .failed("We couldn’t load progress right now.")
        }
    }
}
