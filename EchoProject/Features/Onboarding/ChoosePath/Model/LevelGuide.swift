import Foundation

/// Everything onboarding shows about one Listening level: the overview on
/// Choose path, the custom level dropdown and the "The 4 levels" overlay.
///
/// The level's title comes from the content repository; the rest is onboarding
/// copy taken from Figma (Precoding_FINAL › 02 · Onboarding).
struct LevelGuide: Identifiable, Hashable {
    let number: Int             // 1…4
    let title: String           // "Detection"
    let summary: String         // "Notice when a sound is there"
    let detail: String          // paragraph in "The 4 levels"
    let example: String         // "Turning to look when a bell rings."
    let symbol: String          // SF Symbol shown with the level

    var id: Int { number }

    init(level: Level) {
        number = level.order
        title = level.title
        let copy = Self.copy[level.order] ?? (level.subtitle, "", "", "circle")
        summary = copy.summary
        detail = copy.detail
        example = copy.example
        symbol = copy.symbol
    }

    private static let copy: [Int: (summary: String, detail: String, example: String, symbol: String)] = [
        1: ("Notice when a sound is there",
            "Your child learns to notice that a sound has started or stopped. Practice uses everyday sounds like a bell, a knock or a familiar voice.",
            "Turning to look when a bell rings.",
            "ear.fill"),
        2: ("Tell two sounds apart",
            "Your child learns that two sounds are not the same, such as loud and soft, long and short, or a voice and a drum, before naming them.",
            "Hearing that the drum and the whistle are different.",
            "waveform.path"),
        3: ("Recognise familiar sounds",
            "Your child connects sounds with names. Animals, objects, people and favourite words become easy to recognise by listening alone.",
            "Pointing to the dog when they hear \u{201C}woof\u{201D}.",
            "magnifyingglass.circle.fill"),
        4: ("Understand what they hear",
            "Your child understands words, sentences and directions without lip reading, follows instructions and answers simple questions about stories.",
            "\u{201C}Get your shoes and open the door.\u{201D}",
            "brain.fill")
    ]
}
