import Foundation

/// Decides when what the recogniser wrote down is the word in the passage.
///
/// Words are compared letter by letter (capitals and punctuation are already gone), but a
/// child reading aloud can't control how the recogniser spells what they said, so these
/// also count as the same word:
/// - spelling differences: "favourite" / "favorite", "mum" / "mom";
/// - words that sound the same: "wear" / "where", "to" / "too" / "two";
/// - one word written as two, or two as one: "teddybear", "break fast";
/// - short forms: "I'm" for "I am".
/// The recogniser's own alternatives for each word are tried too (`HeardWord.options`).
///
/// Pure Swift with no frameworks, so it is easy to unit test.
enum SpokenWordMatcher {
    /// Is the heard word this passage word?
    static func matches(_ heard: HeardWord, _ expected: String) -> Bool {
        guard !expected.isEmpty else { return false }
        let accepted = variants(of: expected)
        return heard.options.contains { accepted.contains($0) }
    }

    /// One heard word for two passage words: "teddybear" for "teddy bear", "I'm" for "I am".
    static func joinedWord(_ heard: HeardWord, matches first: String, _ second: String) -> Bool {
        guard !first.isEmpty, !second.isEmpty else { return false }
        return heard.options.contains { option in
            if contractions[option] == [first, second] { return true }
            return variants(of: first).contains { a in variants(of: second).contains { b in a + b == option } }
        }
    }

    /// Two heard words for one passage word: "break fast" for "breakfast", "I am" for "I'm".
    static func splitWords(_ first: HeardWord, _ second: HeardWord, match expected: String) -> Bool {
        guard !expected.isEmpty else { return false }
        if let parts = contractions[expected], first.options.contains(parts[0]), second.options.contains(parts[1]) {
            return true
        }
        let accepted = variants(of: expected)
        return first.options.contains { a in second.options.contains { b in accepted.contains(a + b) } }
    }

    /// The heard word could be the start of the passage word, still being said
    /// ("hun" while the child is saying "hungry").
    static func mayBeStartOf(_ heard: HeardWord, _ expected: String) -> Bool {
        let accepted = variants(of: expected)
        return heard.options.contains { option in
            !option.isEmpty && accepted.contains { $0.count > option.count && $0.hasPrefix(option) }
        }
    }

    /// "um", "uh"…: never an attempt at a word.
    static func isFiller(_ heard: HeardWord) -> Bool {
        heard.options.first.map(fillers.contains) ?? false
    }

    static func variants(of word: String) -> Set<String> {
        sameWord[word, default: []].union([word])
    }

    // MARK: - Word lists

    private static let fillers: Set<String> = ["um", "umm", "uh", "uhh", "er", "erm", "hmm", "ah", "mm"]

    /// Words that are spelled differently or sound the same.
    private static let groups: [Set<String>] = [
        // Spelling
        ["favourite", "favorite"], ["colour", "color"], ["grey", "gray"], ["mum", "mom", "mam", "mummy", "mommy"],
        ["okay", "ok"], ["pyjamas", "pajamas"], ["neighbour", "neighbor"], ["theatre", "theater"],
        ["grandma", "granma", "grandmom"], ["grandpa", "granpa"], ["teddy", "teddie"],
        // Sound the same
        ["to", "too", "two"], ["for", "four"], ["no", "know"], ["right", "write"], ["see", "sea"],
        ["by", "buy", "bye"], ["there", "their", "they're"], ["one", "won"], ["eight", "ate"],
        ["hear", "here"], ["be", "bee"], ["i", "eye"], ["new", "knew"], ["night", "knight"],
        ["red", "read"], ["blue", "blew"], ["son", "sun"], ["meet", "meat"], ["week", "weak"],
        ["flower", "flour"], ["tail", "tale"], ["pair", "pear"], ["dear", "deer"], ["hole", "whole"],
        ["road", "rode"], ["wear", "where"], ["our", "hour"], ["its", "it's"], ["your", "you're"]
    ]

    private static let sameWord: [String: Set<String>] = {
        var index: [String: Set<String>] = [:]
        for group in groups {
            for word in group { index[word, default: []].formUnion(group) }
        }
        return index
    }()

    private static let contractions: [String: [String]] = [
        "i'm": ["i", "am"], "it's": ["it", "is"], "we're": ["we", "are"], "you're": ["you", "are"],
        "they're": ["they", "are"], "he's": ["he", "is"], "she's": ["she", "is"], "that's": ["that", "is"],
        "let's": ["let", "us"], "i'll": ["i", "will"], "we'll": ["we", "will"], "you'll": ["you", "will"],
        "i've": ["i", "have"], "we've": ["we", "have"], "don't": ["do", "not"], "can't": ["can", "not"],
        "cannot": ["can", "not"], "isn't": ["is", "not"], "aren't": ["are", "not"], "won't": ["will", "not"],
        "didn't": ["did", "not"], "doesn't": ["does", "not"], "wasn't": ["was", "not"], "what's": ["what", "is"]
    ]
}
