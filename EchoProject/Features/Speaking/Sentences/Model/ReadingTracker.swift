import Foundation

/// Lines up what the child said with the passage, word by word. The same alignment
/// drives the live highlighting and the accuracy score, so they always agree.
///
/// The heard words are lined up with the passage using a word-level sequence alignment
/// (edit distance), which picks the cheapest explanation of what was said. Words are
/// compared exactly, letter by letter, allowing only the spelling and sound-alike
/// differences in `SpokenWordMatcher`:
/// - **match**: the heard word is the passage word → green;
/// - **wrong word**: a different word said in its place → red, and reading moves on to
///   the next word (also for the very first and the very last word);
/// - **skipped word**: a passage word with nothing said for it → red;
/// - **joined or split**: "teddybear", "break fast", "I'm" for "I am" → green;
/// - **repeat or self-correction**: a heard word equal to one of the last few passage
///   words is not a new attempt; if that word was red it turns green, otherwise it is
///   ignored, so nothing is counted twice;
/// - **extra word**: anything else ("um", a stray word) never shifts the words after it.
///
/// While the child is still talking, the recogniser keeps rewriting its last word
/// ("hun" → "hungry"). With `settled: false` such a half-heard last word stays the current
/// word instead of turning red; `settled: true` (once the child has finished) scores it.
///
/// Pure Swift with no frameworks, so it is easy to unit test.
struct ReadingTracker {
    /// How far back a repeated word may correct a red word. The ViewModel also uses it
    /// to know when the child is on the last few words.
    static let lookAhead = 3

    /// Alignment costs. A wrong word is cheaper than an ignored extra word, so a word that
    /// doesn't match counts against the current word and reading moves on; a repeat of a
    /// recent word is cheapest of all, so repeats never push the current word on.
    private enum Cost {
        static let wrongWord = 10
        static let skippedWord = 10
        static let extraWord = 15
        static let repeatedWord = 2
        static let filler = 0
        static let joinedOrSplit = 1
    }

    /// The words to say, cleaned up: ["every", "morning", "i", …]. Empty for lone symbols.
    let words: [String]

    /// Index of the current word. Everything before it has been read.
    private(set) var position = 0
    /// Words said correctly.
    private(set) var matched: Set<Int> = []
    /// The current word has been partly heard and the recogniser is still working on it.
    private(set) var isHearingCurrentWord = false

    init(words: [String]) {
        self.words = words
        position = words.firstIndex { !$0.isEmpty } ?? words.count
    }

    var isFinished: Bool { position >= words.count }

    /// Words with something to say, for the score.
    var expectedCount: Int { words.filter { !$0.isEmpty }.count }

    var correctCount: Int { matched.count }

    /// Words still to read, counting the current one.
    var remainingCount: Int {
        words[min(position, words.count)...].filter { !$0.isEmpty }.count
    }

    /// The passage's last word was said correctly.
    var isLastWordCorrect: Bool {
        guard let last = words.lastIndex(where: { !$0.isEmpty }) else { return true }
        return matched.contains(last)
    }

    /// Words the child has passed without saying them correctly.
    var incorrect: Set<Int> {
        Set((0..<min(position, words.count)).filter { !words[$0].isEmpty && !matched.contains($0) })
    }

    /// Re-aligns everything heard so far in this passage. Never moves backwards, so a
    /// recogniser changing its mind can't take away words already read.
    mutating func align(heard: [HeardWord], settled: Bool = true) {
        let result = Self.alignment(words, heard: heard, settled: settled)
        guard result.position > position
                || (result.position == position && result.matched.count >= matched.count) else { return }
        position = result.position
        matched = result.matched
        isHearingCurrentWord = result.isHearingCurrentWord
    }

    /// Plain text, for tests and previews.
    mutating func align(heard text: String, settled: Bool = true) {
        align(heard: HeardWord.words(in: text), settled: settled)
    }

    // MARK: - Alignment

    struct Alignment: Equatable {
        var position: Int
        var matched: Set<Int>
        var isHearingCurrentWord: Bool
    }

    /// The finished alignment, for the score.
    static func aligned(_ words: [String], heard: [HeardWord]) -> (position: Int, matched: Set<Int>) {
        let result = alignment(words, heard: heard, settled: true)
        return (result.position, result.matched)
    }

    private enum Step { case match, wrong, skip, joined, split, repeated, extra }

    private struct Score: Comparable {
        var cost: Int
        /// Minus the correct words, so ties prefer more correct words.
        var missing: Int
        static func < (a: Score, b: Score) -> Bool { (a.cost, a.missing) < (b.cost, b.missing) }
    }

    /// Lines up `heard` with the start of `words` (the rest is simply not read yet).
    static func alignment(_ words: [String], heard: [HeardWord], settled: Bool) -> Alignment {
        // Only words with something to say take part.
        let expected = words.indices.filter { !words[$0].isEmpty }
        let m = expected.count, n = heard.count

        func word(_ j: Int) -> String { words[expected[j]] }
        func isMatch(_ i: Int, _ j: Int) -> Bool { SpokenWordMatcher.matches(heard[i], word(j)) }

        /// Cost of heard word `i` not being an attempt at passage word `j`.
        func extraCost(_ i: Int, before j: Int) -> (cost: Int, step: Step) {
            if SpokenWordMatcher.isFiller(heard[i]) { return (Cost.filler, .extra) }
            if (max(0, j - lookAhead)..<j).contains(where: { isMatch(i, $0) }) { return (Cost.repeatedWord, .repeated) }
            return (Cost.extraWord, .extra)
        }

        // score[i][j]: best way to explain the first i heard words with the first j passage words.
        let worst = Score(cost: .max / 4, missing: 0)
        var score = Array(repeating: Array(repeating: worst, count: m + 1), count: n + 1)
        var step = Array(repeating: Array(repeating: Step.match, count: m + 1), count: n + 1)
        score[0][0] = Score(cost: 0, missing: 0)

        for i in 0...n {
            for j in 0...m where i > 0 || j > 0 {
                // Candidates in order of preference when scores tie.
                var best = worst, bestStep = Step.match
                func consider(_ from: Score, cost: Int, correct: Int, _ kind: Step) {
                    let candidate = Score(cost: from.cost + cost, missing: from.missing - correct)
                    if candidate < best { best = candidate; bestStep = kind }
                }
                if i > 0, j > 0 {
                    if isMatch(i - 1, j - 1) {
                        consider(score[i - 1][j - 1], cost: 0, correct: 1, .match)
                    } else {
                        consider(score[i - 1][j - 1], cost: Cost.wrongWord, correct: 0, .wrong)
                    }
                }
                if i > 0, j > 1, SpokenWordMatcher.joinedWord(heard[i - 1], matches: word(j - 2), word(j - 1)) {
                    consider(score[i - 1][j - 2], cost: Cost.joinedOrSplit, correct: 2, .joined)
                }
                if i > 1, j > 0, SpokenWordMatcher.splitWords(heard[i - 2], heard[i - 1], match: word(j - 1)) {
                    consider(score[i - 2][j - 1], cost: Cost.joinedOrSplit, correct: 1, .split)
                }
                let extra = i > 0 ? extraCost(i - 1, before: j) : nil
                if let extra, extra.step == .repeated {
                    consider(score[i - 1][j], cost: extra.cost, correct: 0, .repeated)
                }
                if j > 0 {
                    consider(score[i][j - 1], cost: Cost.skippedWord, correct: 0, .skip)
                }
                if let extra, extra.step == .extra {
                    consider(score[i - 1][j], cost: extra.cost, correct: 0, .extra)
                }
                score[i][j] = best
                step[i][j] = bestStep
            }
        }

        // Everything heard must be explained; the passage may be only partly read.
        // Ties go to the shorter reading, so nothing is marked read too early.
        var j = (0...m).min { (score[n][$0], $0) < (score[n][$1], $1) } ?? 0
        var reached = j

        // Walk back to recover the steps: (kind, last heard word used, last passage word).
        var steps: [(kind: Step, heard: Int, word: Int)] = []
        var i = n
        while i > 0 || j > 0 {
            let kind = step[i][j]
            switch kind {
            case .match, .wrong:
                steps.append((kind, i - 1, j - 1)); i -= 1; j -= 1
            case .joined:
                steps.append((kind, i - 1, j - 1)); i -= 1; j -= 2
            case .split:
                steps.append((kind, i - 1, j - 1)); i -= 2; j -= 1
            case .skip:
                steps.append((kind, -1, j - 1)); j -= 1
            case .repeated, .extra:
                steps.append((kind, i - 1, j)); i -= 1
            }
        }
        steps.reverse()

        // The last word heard may still be on its way: keep it as the current word.
        var isHearingCurrentWord = false
        if !settled, let last = steps.last, last.kind == .wrong, last.heard == n - 1,
           SpokenWordMatcher.mayBeStartOf(heard[n - 1], word(last.word)) {
            steps.removeLast()
            reached = last.word
            isHearingCurrentWord = true
        }

        var matched: Set<Int> = []
        for (kind, heardIndex, wordIndex) in steps {
            switch kind {
            case .match, .split:
                matched.insert(expected[wordIndex])
            case .joined:
                matched.insert(expected[wordIndex - 1])
                matched.insert(expected[wordIndex])
            case .repeated:
                // Saying a recent red word again turns it green.
                let recent = max(0, wordIndex - lookAhead)..<wordIndex
                if let fix = recent.reversed().first(where: { !matched.contains(expected[$0]) && isMatch(heardIndex, $0) }) {
                    matched.insert(expected[fix])
                }
            case .wrong, .skip, .extra:
                break
            }
        }

        let position = reached < m ? expected[reached] : words.count
        return Alignment(position: position, matched: matched, isHearingCurrentWord: isHearingCurrentWord)
    }
}
