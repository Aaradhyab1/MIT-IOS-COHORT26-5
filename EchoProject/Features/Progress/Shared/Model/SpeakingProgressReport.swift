import Foundation

/// Everything the Speaking progress screen shows.
struct SpeakingProgressReport: Hashable {
    let subtitle: String
    let level: ProgressLevel
    let newWordsThisWeek: Int
    /// New words learnt per day.
    let dailyWords: [ProgressDayValue]
    let wordExamples: [String]
    let moments: [ProgressSpeechMoment]
    let path: [ProgressPathStep]
    let footnote: String
}
