import Foundation
import CoreGraphics

/// Which pictures the shared completion screen shows, per exercise or level and result.
///
/// Every exercise ends on the same completion screen; only the pictures change,
/// as in the Figma completion frames of each section. A level not listed here
/// shows the default symbol until its art is added.
struct CompletionArtwork {
    let images: [String]
    /// Size of each picture.
    var width: CGFloat = 170
    var height: CGFloat = 174
    /// Moves the art up, so more of a tall picture shows above the card.
    var lift: CGFloat = 0
    /// Crops the picture to a circle with a white ring (Differentiation's elephant).
    var circular = false

    static func artwork(exerciseId: String, levelId: String?, outcome: Outcome) -> CompletionArtwork {
        // Exercises whose story has no animals get their own picture.
        switch exerciseId {
        case "detection.hide-and-seek.doorbell":
            switch outcome {
            case .greatJob:
                return CompletionArtwork(images: ["img_house_ringing"], width: 260, height: 216, lift: 70)
            case .almostThere:
                return CompletionArtwork(images: ["img_house"], width: 260, height: 216, lift: 70)
            case .keepPractising:
                return CompletionArtwork(images: [])
            }
        default:
            break
        }

        switch levelId {
        case "listening.detection":
            switch outcome {
            case .greatJob: return CompletionArtwork(images: ["img_dog_happy", "img_cat_happy"])
            case .almostThere: return CompletionArtwork(images: ["img_dog_worried", "img_cat_worried"])
            case .keepPractising: return CompletionArtwork(images: [])
            }
        case "listening.differentiation":
            // Echo with a checklist, in a white ring (Figma "Differentiation / Completion").
            return CompletionArtwork(images: ["img_elephant_practice"], width: 172, height: 172, lift: 45, circular: true)
        case "listening.identification":
            // Echo with a checklist, in a white ring (Figma "Instruments / Completion").
            return CompletionArtwork(images: ["img_elephant_practice"], width: 172, height: 172, lift: 45, circular: true)
        case "listening.comprehension":
            return CompletionArtwork(images: ["img_story-complete"])
        case "speaking.words":
            return CompletionArtwork(images: [outcome == .greatJob ? "img_speaking_girl_proud" : "img_speaking_cheer_girl"])
        default:
            return CompletionArtwork(images: [])
        }
    }
}
