import Foundation

/// Home's heading for each Listening level: "Level 3 - Identify more sounds" and its line.
/// Level 3 and the Level 4 "Understand sounds" title are from Figma.
/// TODO(copy): the others follow the same voice; check them with the designer.
enum ListeningLevelCopy {
    static func title(forLevel number: Int) -> String {
        switch number {
        case 1: "Notice sounds"
        case 2: "Tell sounds apart"
        case 3: "Identify more sounds"
        case 4: "Understand sounds"
        default: "Keep listening"
        }
    }

    static func subtitle(forLevel number: Int) -> String {
        switch number {
        case 1: "Pick a game, then listen for the sound."
        case 2: "Pick a game, then find the one that's different."
        case 3: "Pick a category, then name what you hear."
        case 4: "Pick a story, then answer the questions."
        default: ""
        }
    }
}
