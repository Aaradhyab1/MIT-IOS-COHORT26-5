import Foundation

extension AppContainer {
    /// Where the Progress screens get their summaries. Backed by hardcoded data for now;
    /// swap this for a service built on `progress` once real results are stored.
    var progressReports: any ProgressReportService {
        MockProgressReportService()
    }
}
