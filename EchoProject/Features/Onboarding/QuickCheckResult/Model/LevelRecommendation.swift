import Foundation

/// The level shown in the "Recommended starting level" card: "Level 3 · Identification",
/// one line about it, and its icon.
struct LevelRecommendation: Hashable {
    let number: Int
    let heading: String         // "Level 3 · Identification"
    let blurb: String           // "Name everyday sounds, animals and voices."
    let symbol: String          // SF Symbol in the tile

    init(level: Level) {
        number = level.order
        heading = "Level \(level.order) \u{00B7} \(level.title)"
        let copy = Self.copy[level.order] ?? (level.subtitle, "star.fill")
        blurb = copy.blurb
        symbol = copy.symbol
    }

    /// Level 3 is from Figma. TODO(copy): levels 1, 2 and 4 have no result frame yet.
    private static let copy: [Int: (blurb: String, symbol: String)] = [
        1: ("Notice when sounds start and stop.", "ear"),
        2: ("Tell different sounds apart.", "waveform.path"),
        3: ("Name everyday sounds, animals and voices.", "magnifyingglass"),
        4: ("Understand stories, questions and directions.", "brain")
    ]
}
