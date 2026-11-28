import Foundation

/// The "How to play" steps and item word shown on Before you start.
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
    /// What one round is called on the meta pill, e.g. "10 sounds".
    let itemWord: String

    static func forType(_ type: ExerciseType) -> ExerciseInstructions {
        switch type {
        case .listenAndRespond:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Play the sound", "Tap play and listen closely."),
                    ("Did you hear it?", "Tap I Heard It or I Didn't Hear It. Every honest answer counts.")
                ]),
                itemWord: "sounds"
            )
        case .oddOneOut:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Listen to each friend", "Tap Start. Mia, Leo and Zoe each make a sound."),
                    ("Find the different one", "Tap the friend whose sound was different.")
                ]),
                itemWord: "rounds"
            )
        case .pictureChoice:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Hear each sound", "Tap each picture to hear its sound, then start the game."),
                    ("Play the sound", "Tap play. You can replay it as often as you like."),
                    ("Tap the picture", "Tap the picture that made the sound.")
                ]),
                itemWord: "sounds"
            )
        case .storyPlayer:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Listen to each page", "Tap play to hear the page, then tap Next."),
                    ("Put the story in order", "Drag each picture to the number it happened."),
                    ("Match who did what", "Draw a line from each character to what they did.")
                ]),
                itemWord: "rounds"
            )
        case .ordering:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Listen to the story", "Listen to what happens, as often as you like."),
                    ("Put it in order", "Drag each picture to the number it happened.")
                ]),
                itemWord: "rounds"
            )
        case .matching:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Listen", "Listen to the story, as often as you like."),
                    ("Match who did what", "Draw a line from each character to what they did.")
                ]),
                itemWord: "rounds"
            )
        case .listenAndRecord:
            // Words; Sounds uses `forExercise`, which picks `soundSteps`.
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Listen first", "Tap play to hear the word."),
                    ("Say it out loud", "Tap Record and say the word."),
                    ("Get help if you need it", "Tap Hear pronunciation, then try again or continue.")
                ]),
                itemWord: "words"
            )
        case .readAlong:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Read it out loud", "Tap the microphone and read, one word at a time."),
                    ("Watch the words", "Words turn green when said right and red when not."),
                    ("Tap a word", "Tap any word to hear how it is said.")
                ]),
                itemWord: "reads"
            )
        case .conversation:
            return ExerciseInstructions(
                steps: makeSteps([
                    ("Listen to the shopkeeper", "She asks a question and names the choices, like chocolate, vanilla or strawberry."),
                    ("Say your choice", "The microphone turns on by itself. Say one of the choices; it stops when it hears you."),
                    ("Get your ice cream", "Pick a flavour, a cup or cone, and a topping to see your ice cream on the counter.")
                ]),
                itemWord: "turns"
            )
        }
    }

    /// The steps for one exercise. Same as `forType`, except Sounds, which shares its
    /// template with Words but plays differently.
    static func forExercise(_ exercise: Exercise) -> ExerciseInstructions {
        if exercise.id == "sounds.vowel" {
            return ExerciseInstructions(steps: soundFriendSteps, itemWord: "sounds")
        }
        if exercise.levelId == "speaking.sounds" {
            return ExerciseInstructions(steps: soundSteps, itemWord: "sounds")
        }
        return forType(exercise.type)
    }

    /// Consonant, syllable and pattern sounds: listen, then say it.
    private static let soundSteps = makeSteps([
        ("Listen first", "Tap play to hear the sound."),
        ("Say it out loud", "Tap the microphone and say it the same way.")
    ])

    /// Vowel sounds: the sound-friend game, the only one with stars.
    private static let soundFriendSteps = makeSteps([
        ("Listen", "Hear how your sound friend says its sound."),
        ("Say it 3 times", "Tap the microphone and say the sound. Each good try moves your friend along."),
        ("Help your friend get home", "Collect a star each time, until your friend reaches its goal.")
    ])

    // MARK: - Helpers

    /// Numbers the steps 1, 2, 3 in the order given.
    private static func makeSteps(_ pairs: [(String, String)]) -> [Step] {
        var steps: [Step] = []
        for (index, pair) in pairs.enumerated() {
            steps.append(Step(number: index + 1, title: pair.0, detail: pair.1))
        }
        return steps
    }
}
