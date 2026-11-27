import Foundation

/// Finds which choice the child said, in whatever words they used:
/// "I want chocolate please" → Chocolate.
///
/// The answer only counts when exactly one choice was said. No choice ("mango") or two
/// choices ("chocolate and vanilla") returns nil, and the shopkeeper asks again.
/// Pure Swift, so it is easy to unit test.
enum ChoiceMatcher {
    /// Longer words may be slightly misheard ("strawbery"); short ones must match exactly,
    /// so "come" does not count as "cone".
    static let similarityNeeded = 0.75

    static func choice(in heard: String, from choices: [ConversationChoice]) -> ConversationChoice? {
        let heardWords = PronunciationScorer.words(in: heard).map(singular)
        let said = choices.filter { choice in
            let choiceWords = PronunciationScorer.words(in: choice.label).map(singular)
            return choiceWords.allSatisfy { choiceWord in
                heardWords.contains { matches($0, choiceWord) }
            }
        }
        return said.count == 1 ? said.first : nil
    }

    private static func matches(_ heardWord: String, _ choiceWord: String) -> Bool {
        if heardWord == choiceWord { return true }
        guard choiceWord.count > 4 else { return false }
        return PronunciationScorer.similarity(heardWord, choiceWord) >= similarityNeeded
    }

    /// "cherries" → "cherry", "cones" → "cone", so plurals still count.
    private static func singular(_ word: String) -> String {
        if word.count > 4, word.hasSuffix("ies") { return String(word.dropLast(3)) + "y" }
        if word.count > 3, word.hasSuffix("s"), !word.hasSuffix("ss") { return String(word.dropLast()) }
        return word
    }
}
