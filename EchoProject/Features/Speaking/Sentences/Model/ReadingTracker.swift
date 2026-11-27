import Foundation

/// Follows the child through a passage while they read it aloud.
///
/// The speech recogniser keeps sending everything it has heard so far. The tracker
/// walks through those words and moves forward in the passage each time one matches.
/// A word lights up only when it is heard exactly (ignoring capitals and punctuation),
/// the same rule `ReadingAccuracy` uses for the score:
/// - a missed word is skipped once the child is up to three words further on;
/// - it never moves backwards, even when the recogniser changes its mind.
///
/// Pure Swift with no frameworks, so it is easy to unit test.
struct ReadingTracker {
    /// How many words ahead a heard word may match, skipping the ones in between.
    static let lookAhead = 3

    /// The words to say, cleaned up: ["every", "morning", "i", …].
    let words: [String]

    /// Index of the next word to read. Everything before it has been read or skipped.
    private(set) var position = 0
    /// Words that were skipped because the recogniser never heard them.
    private(set) var skipped: Set<Int> = []
    /// Where the current listening session started; heard text is counted from here.
    private var sessionStart = 0

    init(words: [String]) {
        self.words = words
        skipEmptyWords()
    }

    var isFinished: Bool { position >= words.count }

    /// Words read correctly, for the score.
    var correctCount: Int { min(position, words.count) - skipped.count }

    /// Call when listening starts or resumes: the recogniser starts a fresh transcript.
    mutating func beginSession() {
        sessionStart = position
    }

    /// Moves forward using everything heard since `beginSession()`.
    mutating func update(heard: [HeardWord]) {
        var index = sessionStart
        var missed: [Int] = []
        for heardWord in heard {
            index = Self.skippingEmpty(words, from: index)
            guard index < words.count else { break }
            let lastCandidate = min(index + Self.lookAhead, words.count - 1)
            for candidate in index...lastCandidate where heardWord.matches(words[candidate]) {
                missed += (index..<candidate).filter { !words[$0].isEmpty }
                index = candidate + 1
                break
            }
        }
        index = Self.skippingEmpty(words, from: index)
        guard index > position else { return }
        position = index
        skipped.formUnion(missed)
    }

    /// Plain text, for tests and previews.
    mutating func update(heard text: String) {
        update(heard: HeardWord.words(in: text))
    }

    // MARK: - Private

    /// Punctuation on its own ("—") has nothing to say, so it never blocks the child.
    private mutating func skipEmptyWords() {
        position = Self.skippingEmpty(words, from: position)
    }

    private static func skippingEmpty(_ words: [String], from index: Int) -> Int {
        var index = index
        while index < words.count, words[index].isEmpty { index += 1 }
        return index
    }
}
