import Foundation

/// Stands in for the real progress store in the app, previews and tests.
/// Set `failsToLoad` to see the error state.
final class MockProgressReportService: ProgressReportService {
    var failsToLoad: Bool
    var overviewReport: ProgressOverviewReport
    var listeningReport: ListeningProgressReport
    var speakingReport: SpeakingProgressReport
    private(set) var loadCount = 0

    init(failsToLoad: Bool = false) {
        self.failsToLoad = failsToLoad
        overviewReport = DummyData.progressOverview
        listeningReport = DummyData.listeningProgress
        speakingReport = DummyData.speakingProgress
    }

    func overview() async throws -> ProgressOverviewReport {
        try check()
        return overviewReport
    }

    func listening() async throws -> ListeningProgressReport {
        try check()
        return listeningReport
    }

    func speaking() async throws -> SpeakingProgressReport {
        try check()
        return speakingReport
    }

    private func check() throws {
        loadCount += 1
        if failsToLoad { throw ProgressReportError.unavailable }
    }
}
