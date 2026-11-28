import Foundation

/// One part of a word for pronunciation help: a syllable ("PLE" in apple) or, for short
/// words, the first sound or the rest ("S", "UN" in sun).
struct WordPart: Equatable {
    /// Shown on the chip, e.g. "UN".
    let chip: String
    /// How to say the part, spelled the way it sounds so the voice reads it as one
    /// smooth syllable, e.g. "wah" for "WA". Nil means the voice reads the chip text.
    let sound: String?
}

/// One word to practise, in the shape the Words screen needs.
///
/// Built from the shared `ExerciseItem`, so the Words View and ViewModel never depend on
/// how content is stored. Plain data only: no services, no UI state.
struct WordPracticeItem: Identifiable, Equatable {
    let id: String
    /// The word shown and spoken, e.g. "Sun".
    let word: String
    /// The word broken into parts, e.g. "S" + "UN".
    let parts: [WordPart]
    /// How to say it, e.g. "s · un → sun".
    let hint: String
    /// What counts as said right, e.g. ["sun", "son"].
    let acceptedAnswers: [String]

    init(_ item: ExerciseItem) {
        let word = item.text ?? ""
        self.id = item.id
        self.word = word
        self.parts = (item.options ?? []).map { WordPart(chip: $0.label, sound: $0.pronunciation) }
        self.hint = item.hint ?? ""
        self.acceptedAnswers = item.acceptedAnswers ?? [word]
    }

    /// Chip texts, e.g. ["S", "UN"].
    var soundChips: [String] { parts.map(\.chip) }
}
