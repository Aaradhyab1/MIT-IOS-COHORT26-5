import Foundation

/// The little story around one Story Hide & Seek exercise: where the sound comes from,
/// what the bubble says, and what the child sees after answering.
///
/// The hiding place never changes while the sound plays, so the child answers from
/// what they heard, not from what they saw.
struct DetectionStory {
    enum HidingSpot {
        /// An animal hides behind a bush and rises up after the answer.
        case bush
        /// A house with a doorbell. After the answer the doorbell rings.
        case house
    }

    /// What the screen shows for one sound after the child answers.
    struct Reveal {
        let title: String           // "Ding-dong!"
        let subtitle: String        // "That was the doorbell."
        let name: String            // "doorbell", used in "That was the doorbell."
        let houseImage: String?     // house picture with the doorbell ringing
    }

    let hidingSpot: HidingSpot
    let readyLine: String           // first round, before Play
    let nextReadyLine: String       // later rounds, before Play
    let playingLine: String
    let nextLine: String            // after a correct answer, more rounds to go
    let finishedLine: String        // after a correct answer on the last round
    let silentTitle: String         // reveal of a round with no sound
    let silentSubtitle: String?
    let reveals: [String: Reveal]   // keyed by the item's audio clip, e.g. "snd_doorbell"

    // MARK: - Stories

    static func forExercise(_ exerciseId: String) -> DetectionStory {
        switch exerciseId {
        case "detection.hide-and-seek.doorbell": return .doorbell
        default: return .animals
        }
    }

    /// Listen for the Animal: animals hide behind the bush. Reveal text comes from the item.
    static let animals = DetectionStory(
        hidingSpot: .bush,
        readyLine: "An animal is hiding.",
        nextReadyLine: "Is something hiding?",
        playingLine: "The animal is making a sound.",
        nextLine: "Let’s find another animal.",
        finishedLine: "You heard both animals!",
        silentTitle: "Nothing was hiding!",
        silentSubtitle: "It was quiet this time.",
        reveals: [:]
    )

    /// Hear the Doorbell: the doorbell rings, then a quiet round where nobody rings.
    static let doorbell = DetectionStory(
        hidingSpot: .house,
        readyLine: "Someone is at the door.",
        nextReadyLine: "Is someone at the door?",
        playingLine: "Listen carefully…",
        nextLine: "Let’s listen for the next sound.",
        finishedLine: "You listened really well!",
        silentTitle: "It was quiet!",
        silentSubtitle: "Nobody rang the doorbell.",
        reveals: [
            "snd_doorbell": Reveal(title: "Ding-dong!", subtitle: "That was the doorbell.",
                                   name: "doorbell", houseImage: "img_house_ringing")
        ]
    )
}
