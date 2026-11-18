import Foundation

/// Hardcoded sample data for the clickable build (no database or backend yet).
///
/// Rules:
/// - Only repositories read `DummyData`. Views and ViewModels never do
///   (scripts/check-mvvm.sh fails the PR if they do).
/// - Copy titles, counts and text from PRECODING so screens match the prototype.
///   Lines marked `TODO(copy)` still need the exact prototype wording.
/// - Asset names ("img_…", "snd_…", "level_…", "ex_…") are the contract with the
///   illustrators: add art to Assets.xcassets under these names and it appears
///   with no code change.
enum DummyData {
    static let levels: [Level] = listeningLevels + speakingLevels
    static let exercises: [Exercise] = listeningExercises + speakingExercises
}

// MARK: - Item builders shared by the content files

extension DummyData {
    /// Detection: play a sound, ask "Did you hear it?".
    static func listenItem(_ id: String, sound: String) -> ExerciseItem {
        ExerciseItem(
            id: id,
            prompt: "Did you hear it?",
            audio: "snd_\(sound)",
            image: "img_\(sound)"
        )
    }

    /// Differentiation: Mia, Leo and Zoe each make a sound; one is different.
    static func oddOneOutItem(_ id: String, prompt: String, odd: EchoCharacter) -> ExerciseItem {
        let friends: [EchoCharacter] = [.mia, .leo, .zoe]
        return ExerciseItem(
            id: id,
            prompt: prompt,
            options: friends.map { friend in
                Option(
                    id: friend.rawValue,
                    label: friend.rawValue.capitalized,
                    audio: "snd_\(id)_\(friend.rawValue)",
                    speaker: friend
                )
            },
            correctOptionId: odd.rawValue
        )
    }

    /// Identification: hear a word, pick it from four pictures.
    static func pictureItem(_ id: String, answer: String, choices: [String]) -> ExerciseItem {
        ExerciseItem(
            id: id,
            prompt: "Which one did you hear?",          // TODO(copy)
            audio: "snd_\(answer)",
            options: choices.map { Option(id: $0, label: $0.capitalized, image: "img_\($0)") },
            correctOptionId: answer
        )
    }

    /// Speaking: the model sound or word the child listens to, then records.
    static func recordItem(_ id: String, text: String) -> ExerciseItem {
        ExerciseItem(
            id: id,
            prompt: "Listen, then say it",               // TODO(copy)
            audio: "snd_\(id)",
            image: "img_\(id)",
            text: text,
            speaker: .echo
        )
    }
}
