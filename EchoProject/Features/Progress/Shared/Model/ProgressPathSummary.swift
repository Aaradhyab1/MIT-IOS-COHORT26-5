import Foundation

/// A learning path card on the overview.
struct ProgressPathSummary: Identifiable, Hashable {
    let track: ProgressTrack
    let level: ProgressLevel
    let stats: [ProgressPathStat]

    var id: ProgressTrack { track }
}
