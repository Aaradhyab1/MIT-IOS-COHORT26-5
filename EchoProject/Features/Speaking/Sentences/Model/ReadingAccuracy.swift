import Foundation

/// Scores a reading: how many of the passage's words the child said exactly.
///
/// accuracy = correctly matched words ÷ expected words × 100
///
/// Each heard word is compared with the expected word letter by letter, ignoring
/// capital letters and punctuation; it only counts when every letter matches.
/// The heard words are lined up with the passage using the longest common
/// subsequence, so:
/// - a skipped word just doesn't match, and the words after it still line up;
/// - a repeated or extra word ("the the", "um") is ignored, never counted twice;
/// - every expected word can be matched at most once.
///
/// Speech recognition confidence is not used. Pure Swift, so it is easy to unit test.
enum ReadingAccuracy {
    /// Lowercase words with punctuation removed: "Every morning," → ["every", "morning"].
    static func words(in text: String) -> [String] {
        PronunciationScorer.words(in: text)
    }

    /// How many expected words were said exactly, in order. A heard word matches when
    /// its text, or one of the alternatives the recogniser considered, equals the word.
    static func correctWords(expected: [String], heard: [HeardWord]) -> Int {
        guard !expected.isEmpty, !heard.isEmpty else { return 0 }
        // previous[j] = best count using the expected words so far and heard[0..<j].
        var previous = Array(repeating: 0, count: heard.count + 1)
        for expectedWord in expected {
            var current = Array(repeating: 0, count: heard.count + 1)
            for (j, heardWord) in heard.enumerated() {
                current[j + 1] = heardWord.matches(expectedWord)
                    ? previous[j] + 1
                    : max(previous[j + 1], current[j])
            }
            previous = current
        }
        return previous[heard.count]
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
