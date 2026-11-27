import Foundation

/// The "How to play" steps, grown-up tip and item word shown on Before you start.
///
/// The copy depends only on the game template (ExerciseType), not on the single exercise,
/// so every exercise of a type shares it. Kept here rather than in `Core/Models`
/// so the frozen models do not change.
///
/// `TODO(copy)`: only the picture-choice text is taken from Figma
/// ("Exercise intro — Before you start · Animals"). The rest follows the same voice
/// and should be checked against the design.
struct ExerciseInstructions {
    struct Step: Identifiable, Hashable {
        let number: Int
        let title: String
        let detail: String
        var id: Int { number }
    }

    let steps: [Step]
    let tip: String
    /// What one round is called on the meta pill, e.g. "10 sounds".
    let itemWord: String

    static func forType(_ type: ExerciseType) -> ExerciseInstructions {
        switch type {
        case .listenAndRespond:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Play the sound", "Tap the big play button and listen closely."),
                    ("Did you hear it?", "Tap I heard it or I didn't."),
                    ("Earn a star", "Every honest answer counts. There is no wrong way to play.")
                ]),
                tip: listeningTip,
                itemWord: "sounds"
            )
        case .oddOneOut:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Listen to each friend", "Mia, Leo and Zoe each make a sound. Tap a friend to hear them again."),
                    ("Find the different one", "Tap the friend whose sound was different."),
                    earnAStar
                ]),
                tip: listeningTip,
                itemWord: "rounds"
            )
        case .pictureChoice:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Play the sound", "Tap the big play button. You can replay it as often as you like."),
                    ("Tap the picture", "Four pictures appear. Tap the one that made the sound."),
                    earnAStar
                ]),
                tip: listeningTip,
                itemWord: "sounds"
            )
        case .storyPlayer:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Listen to the story", "Turn the pages and listen to each part."),
                    ("Answer the questions", "Tap the picture that matches what happened."),
                    earnAStar
                ]),
                tip: listeningTip,
                itemWord: "rounds"
            )
        case .ordering:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Listen to the story", "Listen to what happens, as often as you like."),
                    ("Put it in order", "Tap the pictures in the order they happened."),
                    earnAStar
                ]),
                tip: listeningTip,
                itemWord: "rounds"
            )
        case .matching:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Play the sound", "Tap the big play button and listen closely."),
                    ("Match it", "Tap the picture that goes with the sound."),
                    earnAStar
                ]),
                tip: listeningTip,
                itemWord: "rounds"
            )
        case .listenAndRecord:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Listen first", "Tap play to hear how it sounds."),
                    ("Say it out loud", "Tap the microphone and say it the same way."),
                    ("Keep going", "Try again until every round is done. It gets easier each time.")
                ]),
                tip: speakingTip,
                itemWord: "tries"
            )
        case .readAlong:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Read together", "Read the sentence out loud, one word at a time."),
                    ("Tap a word", "Tap any word to hear how it is said."),
                    earnAStar
                ]),
                tip: speakingTip,
                itemWord: "reads"
            )
        case .conversation:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Listen to the shopkeeper", "Hear what they ask. Tap to hear it again."),
                    ("Take your turn", "Tap the microphone and say one of the choices."),
                    ("Get your ice cream", "Finish the order to complete the visit.")
                ]),
                tip: speakingTip,
                itemWord: "turns"
            )
        }
    }

    // MARK: - Shared copy

    private static let earnAStar = ("Earn a star", "Right answers glow green. Wrong ones let you try again, no penalty.")

    // The app never asks for the child's name, so tips say "your child".
    private static let listeningTip = "Sit beside your child and let them tap. If they're unsure, play the sound again before guessing."
    private static let speakingTip = "Sit face to face so your child can watch your lips, then let them try on their own."

    /// Numbers the steps 1, 2, 3 in the order given.
    private static func makeSteps(_ pairs: [(String, String)]) -> [Step] {
        var steps: [Step] = []
        for (index, pair) in pairs.enumerated() {
            steps.append(Step(number: index + 1, title: pair.0, detail: pair.1))
        }
        return steps
    }
}
