import Foundation

/// One word of a passage, as a tappable chip.
struct ReadingWord: Identifiable, Hashable {
    /// Position in the passage (0, 1, 2 …).
    let id: Int
    /// What is shown, with its punctuation: "morning,".
    let text: String
    /// What the child should say, cleaned up: "morning". Empty for a lone symbol.
    let spoken: String
    /// How to say it, for the pronunciation sheet: "MOR-ning".
    let syllables: String
}

/// A sentence, rhyme or short story to read aloud.
///
/// Built from an `ExerciseItem`: `text` is the passage, and each `Option` gives the
/// syllables for one word (`id` "morning", `label` "MOR-ning"). Words without an
/// option show the word itself in capitals ("DOG").
struct ReadingPassage: Identifiable, Hashable {
    let id: String
    let words: [ReadingWord]

    init(item: ExerciseItem) {
        id = item.id
        let syllables = Dictionary(
            (item.options ?? []).map { ($0.id.lowercased(), $0.label) },
            uniquingKeysWith: { first, _ in first }
        )
        let pieces = (item.text ?? "").split(separator: " ").map(String.init)
        words = pieces.enumerated().map { index, piece in
            let spoken = PronunciationScorer.normalized(piece)
            return ReadingWord(
                id: index,
                text: piece,
                spoken: spoken,
                syllables: syllables[spoken] ?? spoken.uppercased()
            )
        }
    }

    /// The passage from one word onwards, as plain text.
    func text(from index: Int) -> String {
        words.dropFirst(index).map(\.text).joined(separator: " ")
    }
}
