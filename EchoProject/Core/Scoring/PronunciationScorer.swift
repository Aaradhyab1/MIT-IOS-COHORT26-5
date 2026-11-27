import Foundation

/// How close a spoken word was to the target.
enum WordVerdict: Equatable {
    case correct
    case close
    case incorrect
}

/// Compares what the speech recogniser heard with the word the child was asked to say.
///
/// Lenient on purpose: young children's speech, especially with hearing aids or cochlear
/// implants, is often recognised imperfectly, so a near miss counts as "close", not wrong.
/// Pure Swift with no frameworks, so it is easy to unit test.
enum PronunciationScorer {
    /// Similarity (0 ... 1) needed to count a word as correct, e.g. "tiger" vs "tigger".
    static let correctThreshold = 0.75
    /// Similarity needed to count as "almost there", e.g. "ball" vs "bowl".
    static let closeThreshold = 0.4

    // MARK: - Cleaning text

    /// Lowercase words with punctuation removed and digits spelled out:
    /// "Up, 2 Dogs!" → ["up", "two", "dogs"].
    static func words(in text: String) -> [String] {
        let cleaned = String(text.lowercased().map { character in
            character.isLetter || character.isNumber || character == "'" ? character : " "
        })
        return cleaned.split(separator: " ").map { spelledOut(String($0)) }
    }

    /// The same words joined by single spaces.
    static func normalized(_ text: String) -> String {
        words(in: text).joined(separator: " ")
    }

    // MARK: - Comparing

    /// 1 means identical, 0 means nothing in common.
    static func similarity(_ first: String, _ second: String) -> Double {
        let longest = max(first.count, second.count)
        guard longest > 0 else { return 1 }
        return 1 - Double(editDistance(first, second)) / Double(longest)
    }

    /// Levenshtein distance: how many single-letter inserts, deletes or swaps turn
    /// one word into the other ("sun" → "son" is 1).
    static func editDistance(_ first: String, _ second: String) -> Int {
        let a = Array(first)
        let b = Array(second)
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }

        var previousRow = Array(0...b.count)
        for i in 1...a.count {
            var currentRow = [i] + Array(repeating: 0, count: b.count)
            for j in 1...b.count {
                let swapCost = a[i - 1] == b[j - 1] ? 0 : 1
                currentRow[j] = min(
                    previousRow[j] + 1,             // delete
                    currentRow[j - 1] + 1,          // insert
                    previousRow[j - 1] + swapCost   // swap
                )
            }
            previousRow = currentRow
        }
        return previousRow[b.count]
    }

    // MARK: - Judging a word

    /// Checks a single word against its accepted answers.
    ///
    /// The child must say only the word. Everything that was heard is compared with the
    /// answer, so a sentence that contains it ("it's a sun") is not counted as right.
    static func judge(heard: String, accepted: [String]) -> WordVerdict {
        let heardWords = words(in: heard)
        guard !heardWords.isEmpty else { return .incorrect }
        let heardWhole = heardWords.joined(separator: " ")

        var best = 0.0
        for answer in accepted.map(normalized) where !answer.isEmpty {
            // Extra words mean it was not just the word.
            guard heardWords.count == words(in: answer).count else { continue }
            best = max(best, similarity(heardWhole, answer))
        }

        if best >= correctThreshold { return .correct }
        if best >= closeThreshold { return .close }
        return .incorrect
    }

    // MARK: - Private

    private static let numberWords = [
        "0": "zero", "1": "one", "2": "two", "3": "three", "4": "four", "5": "five",
        "6": "six", "7": "seven", "8": "eight", "9": "nine", "10": "ten"
    ]

    private static func spelledOut(_ word: String) -> String {
        numberWords[word] ?? word
    }
}
