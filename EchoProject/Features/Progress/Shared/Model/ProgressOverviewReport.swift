import Foundation

/// Everything the Progress overview shows.
struct ProgressOverviewReport: Hashable {
    let week: ProgressWeekSummary
    let paths: [ProgressPathSummary]
}
