import Foundation

/// Which game template plays an exercise. One template = one View + ViewModel pair
/// in Features/*/Templates, reused by every exercise of that type.
enum ExerciseType: String, Codable, Hashable, CaseIterable {
    // Listening
    case listenAndRespond   // Detection: play a sound, "Did you hear it?"
    case oddOneOut          // Differentiation: which one sounds different / same or different
    case pictureChoice      // Identification: hear a word, pick 1 of 4 pictures
    case storyPlayer        // Comprehension: story pages, then picture questions
    case ordering           // Comprehension: put story events in order (template not built yet)
    case matching           // Comprehension: match sounds to pictures (template not built yet)

    // Speaking
    case listenAndRecord    // Sounds and Words: listen to the model, record, repeat
    case readAlong          // Sentences: read along, tap a word to hear it
    case conversation       // Ice cream shop role-play

    var track: Track {
        switch self {
        case .listenAndRespond, .oddOneOut, .pictureChoice, .storyPlayer, .ordering, .matching:
            return .listening
        case .listenAndRecord, .readAlong, .conversation:
            return .speaking
        }
    }
}

struct Exercise: Codable, Identifiable, Hashable {
    let id: String              // "detection.hide-and-seek.animal"
    let levelId: String
    let type: ExerciseType
    let title: String           // "Listen for the Animal"
    let summary: String         // one line under the title on the exercise card
    let collection: String?     // groups exercises in a library, e.g. "Hide & Seek"
    let durationMinutes: Int
    let illustration: String
    let repetitions: Int        // rounds to finish, drives "0/10" on cards
    let items: [ExerciseItem]

    init(
        id: String,
        levelId: String,
        type: ExerciseType,
        title: String,
        summary: String,
        collection: String? = nil,
        durationMinutes: Int = 5,
        illustration: String,
        repetitions: Int = 10,
        items: [ExerciseItem]
    ) {
        self.id = id
        self.levelId = levelId
        self.type = type
        self.title = title
        self.summary = summary
        self.collection = collection
        self.durationMinutes = durationMinutes
        self.illustration = illustration
        self.repetitions = repetitions
        self.items = items
    }
}

/// One question, sound, word, story page or conversation turn inside an exercise.
/// Each template reads only the fields it needs.
struct ExerciseItem: Codable, Identifiable, Hashable {
    let id: String
    let prompt: String?             // "Did you hear it?", "Which one sounds different?"
    let audio: String?              // clip name; dummy audio ignores it
    let image: String?
    let text: String?               // word, sentence, story page or line of dialogue
    let speaker: EchoCharacter?
    let options: [Option]?          // pictureChoice, oddOneOut
    let correctOptionId: String?
    let hint: String?               // Words: how to say it, "sss · uh · nnn → sun"
    let acceptedAnswers: [String]?  // Speaking: what counts as said right ("sun", "son")

    init(
        id: String,
        prompt: String? = nil,
        audio: String? = nil,
        image: String? = nil,
        text: String? = nil,
        speaker: EchoCharacter? = nil,
        options: [Option]? = nil,
        correctOptionId: String? = nil,
        hint: String? = nil,
        acceptedAnswers: [String]? = nil
    ) {
        self.id = id
        self.prompt = prompt
        self.audio = audio
        self.image = image
        self.text = text
        self.speaker = speaker
        self.options = options
        self.correctOptionId = correctOptionId
        self.hint = hint
        self.acceptedAnswers = acceptedAnswers
    }
}

struct Option: Codable, Identifiable, Hashable {
    let id: String
    let label: String
    let image: String?
    let audio: String?
    let speaker: EchoCharacter?     // oddOneOut: Mia, Leo or Zoe "says" the sound

    init(id: String, label: String, image: String? = nil, audio: String? = nil, speaker: EchoCharacter? = nil) {
        self.id = id
        self.label = label
        self.image = image
        self.audio = audio
        self.speaker = speaker
    }
}
