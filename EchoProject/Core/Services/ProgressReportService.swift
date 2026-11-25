import Foundation

/// Builds the summaries shown on the Progress tab. ViewModels only know this protocol;
/// today it is backed by `MockProgressReportService`, later by the real progress store.
protocol ProgressReportService {
    func overview() async throws -> ProgressOverviewReport
    func listening() async throws -> ListeningProgressReport
    func speaking() async throws -> SpeakingProgressReport
}

enum ProgressReportError: Error {
    case unavailable
}
