import Foundation

/// Scores a reading: how many of the passage's words the child said exactly.
///
/// accuracy = correctly matched words ÷ expected words × 100
///
/// Uses the same word-by-word alignment as the live highlighting (`ReadingTracker`):
/// exact letter-by-letter matches, ignoring capitals and punctuation; skipped words
/// count as incorrect, extra or repeated words are ignored and never counted twice,
/// and a word said again right after a mistake is corrected.
/// Speech recognition confidence is not used. Pure Swift, so it is easy to unit test.
enum ReadingAccuracy {
    /// Lowercase words with punctuation removed: "Every morning," → ["every", "morning"].
    static func words(in text: String) -> [String] {
        PronunciationScorer.words(in: text)
    }

    /// How many expected words were said exactly. A heard word matches when its text,
    /// or one of the alternatives the recogniser considered, equals the word.
    static func correctWords(expected: [String], heard: [HeardWord]) -> Int {
        guard !expected.isEmpty, !heard.isEmpty else { return 0 }
        return ReadingTracker.aligned(expected, heard: heard).matched.count
    }

    /// Plain heard words, with no alternatives.
    static func correctWords(expected: [String], heard: [String]) -> Int {
        correctWords(expected: expected, heard: heard.map { HeardWord(options: [$0]) })
    }

    /// Whole-number percentage, 0 when there was nothing to read.
    static func percent(correct: Int, total: Int) -> Int {
        guard total > 0 else { return 0 }
        return Int((Double(min(correct, total)) / Double(total) * 100).rounded())
    }
}

/// The four results on the Sentences completion screen.
enum AccuracyTier: Equatable, CaseIterable {
    case keepTrying     // 0–39 %
    case almostThere    // 40–69 %
    case greatJob       // 70–89 %
    case amazing        // 90–100 %

    init(percent: Int) {
        switch percent {
        case ..<40: self = .keepTrying
        case ..<70: self = .almostThere
        case ..<90: self = .greatJob
        default: self = .amazing
        }
    }

    var title: String {
        switch self {
        case .keepTrying: "Keep trying!"
        case .almostThere: "Almost there!"
        case .greatJob: "Great job!"
        case .amazing: "Amazing!"
        }
    }

    var message: String {
        switch self {
        case .keepTrying: "Let's practise together."
        case .almostThere: "A little more practice and you'll get there!"
        case .greatJob: "You're doing really well!"
        case .amazing: "You did a wonderful job!"
        }
    }

    /// Below 90 % the child can read the passages again.
    var offersTryAgain: Bool { self != .amazing }
}

/// The score shown on the completion screen.
struct SentencesResult: Equatable {
    let correctWords: Int
    let totalWords: Int

    var percent: Int { ReadingAccuracy.percent(correct: correctWords, total: totalWords) }
    var tier: AccuracyTier { AccuracyTier(percent: percent) }
    /// 0 ... 1, for the progress ring.
    var fraction: Double { Double(percent) / 100 }
}
