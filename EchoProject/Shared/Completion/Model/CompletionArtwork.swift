import Foundation

/// Which characters the shared completion screen shows, per level and result.
///
/// Every exercise ends on the same completion screen; only the pictures change,
/// as in the Figma completion frames of each section. A level not listed here
/// shows the default symbol until its art is added.
enum CompletionArtwork {
    static func images(levelId: String?, outcome: Outcome) -> [String] {
        switch levelId {
        case "listening.detection":
            switch outcome {
            case .greatJob: return ["img_dog_happy", "img_cat_happy"]
            case .almostThere: return ["img_dog_worried", "img_cat_worried"]
            case .keepPractising: return []
            }
        case "listening.comprehension":
            return ["img_story-complete"]
        case "speaking.words":
            return [outcome == .greatJob ? "img_speaking_girl_proud" : "img_speaking_cheer_girl"]
        default:
            return []
        }
    }
}
