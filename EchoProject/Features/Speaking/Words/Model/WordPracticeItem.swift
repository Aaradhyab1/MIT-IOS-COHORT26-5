import Foundation

/// One word to practise, in the shape the Words screen needs.
///
/// Built from the shared `ExerciseItem`, so the Words View and ViewModel never depend on
/// how content is stored. Plain data only: no services, no UI state.
struct WordPracticeItem: Identifiable, Equatable {
    let id: String
    /// The word shown and spoken, e.g. "Sun".
    let word: String
    /// Sound chips for pronunciation help, e.g. ["S", "U", "N"].
    let soundChips: [String]
    /// How to say it, e.g. "sss · uh · nnn → sun".
    let hint: String
    /// What counts as said right, e.g. ["sun", "son"].
    let acceptedAnswers: [String]

    init(_ item: ExerciseItem) {
        let word = item.text ?? ""
        self.id = item.id
        self.word = word
        self.soundChips = item.options?.map(\.label) ?? []
        self.hint = item.hint ?? ""
        self.acceptedAnswers = item.acceptedAnswers ?? [word]
    }

    /// What to say for each chip, taken from the hint: ["sss", "uh", "nnn"].
    /// Falls back to the chip letters when there is no hint.
    var spokenSounds: [String] {
        let beforeArrow = hint.components(separatedBy: "→").first ?? ""
        let parts = beforeArrow
            .components(separatedBy: "·")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? soundChips.map { $0.lowercased() } : parts
    }
}
