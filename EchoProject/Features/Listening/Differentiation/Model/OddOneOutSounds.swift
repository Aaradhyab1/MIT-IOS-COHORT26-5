import Foundation

/// Spoken-word contrasts for the Odd Sound Out rounds.
struct OddOneOutSound: Equatable {
    let text: String
    let ipa: String?
    let slowly: Bool
}

enum OddOneOutSounds {
    private struct Contrast {
        let shared: OddOneOutSound
        let different: OddOneOutSound
    }

    /// Each round repeats one familiar word twice and uses a clearly different word once.
    private static let rounds: [Contrast] = [
        Contrast(
            shared: OddOneOutSound(text: "hello", ipa: nil, slowly: false),
            different: OddOneOutSound(text: "hi", ipa: nil, slowly: false)
        ),
        Contrast(
            shared: OddOneOutSound(text: "apple", ipa: nil, slowly: false),
            different: OddOneOutSound(text: "banana", ipa: nil, slowly: false)
        )
    ]

    static func sound(exerciseId: String, roundIndex: Int, isOdd: Bool) -> OddOneOutSound {
        if exerciseId == "differentiation.odd-sound-out" {
            let contrast = rounds[roundIndex % rounds.count]
            return isOdd ? contrast.different : contrast.shared
        }

        // Keep the existing prompts for the other differentiation activities unchanged.
        let syllables: [(String, String)] = [("bah", "dah"), ("moo", "mee"), ("pah", "tah")]
        let pair = syllables[roundIndex % syllables.count]
        if exerciseId == "differentiation.fast-or-slow" {
            return OddOneOutSound(text: "\(pair.0), \(pair.0)", ipa: nil, slowly: !isOdd)
        }
        return OddOneOutSound(text: isOdd ? pair.1 : pair.0, ipa: nil, slowly: true)
    }
}
