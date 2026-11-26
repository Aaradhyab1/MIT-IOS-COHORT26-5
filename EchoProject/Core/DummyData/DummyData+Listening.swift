import Foundation

extension DummyData {

    // MARK: - Levels

    static let listeningLevels: [Level] = [
        Level(
            id: "listening.detection",
            track: .listening,
            order: 1,
            title: "Detection",
            subtitle: "Notice when a sound is there",               // TODO(copy)
            illustration: "level_detection",
            exerciseIds: [
                "detection.hide-and-seek.animal",
                "detection.hide-and-seek.doorbell",
                "detection.hide-and-seek.clap",
                "detection.hide-and-seek.drumbeat"
            ]
        ),
        Level(
            id: "listening.differentiation",
            track: .listening,
            order: 2,
            title: "Differentiation",
            subtitle: "Tell sounds apart",                          // TODO(copy)
            illustration: "level_differentiation",
            exerciseIds: [
                "differentiation.odd-sound-out",
                "differentiation.loud-or-soft",
                "differentiation.high-or-low",
                "differentiation.fast-or-slow",
                "differentiation.beat-match",
                "differentiation.rhythm-match",
                "differentiation.speech-sound-differences"
            ]
        ),
        Level(
            id: "listening.identification",
            track: .listening,
            order: 3,
            title: "Identification",
            subtitle: "Name the sound you hear",                    // TODO(copy)
            illustration: "level_identification",
            exerciseIds: [
                "identification.instruments",
                "identification.animals",
                "identification.nature",
                "identification.objects"
            ]
        ),
        Level(
            id: "listening.comprehension",
            track: .listening,
            order: 4,
            title: "Comprehension",
            subtitle: "Understand stories and instructions",        // TODO(copy)
            illustration: "level_comprehension",
            exerciseIds: [
                "comprehension.story.cat-and-bird",
                "comprehension.story.pip-lost-marble",
                "comprehension.story.brave-firetruck",
                "comprehension.story.olivia-starry-sky",
                "comprehension.ordering",
                "comprehension.matching"
            ]
        )
    ]

    // MARK: - Exercises

    static let listeningExercises: [Exercise] = detection + differentiation + identification + comprehension

    private static let detection: [Exercise] = [
        Exercise(
            id: "detection.hide-and-seek.animal",
            levelId: "listening.detection",
            type: .listenAndRespond,
            title: "Listen for the Animal",
            summary: "Find the hidden animal by its sound",         // TODO(copy)
            collection: "Story Hide & Seek",
            illustration: "ex_hide-and-seek-animal",
            items: [
                ExerciseItem(
                    id: "animal-1",
                    prompt: "Did you hear it?",
                    audio: "snd_cat",
                    image: "img_cat_happy",
                    text: "cat"
                ),
                ExerciseItem(
                    id: "animal-2",
                    prompt: "Did you hear it?",
                    audio: "snd_dog",
                    image: "img_dog_happy",
                    text: "dog"
                )
            ]
        ),
        Exercise(
            id: "detection.hide-and-seek.doorbell",
            levelId: "listening.detection",
            type: .listenAndRespond,
            title: "Hear the Doorbell",
            summary: "Who is at the door?",                         // TODO(copy)
            collection: "Story Hide & Seek",
            illustration: "ex_hide-and-seek-doorbell",
            items: [
                listenItem("doorbell-1", sound: "doorbell"),
                // Silent round: nothing plays, so "I didn't hear it" is the right answer.
                ExerciseItem(id: "doorbell-2", prompt: "Did you hear it?")
            ]
        ),
        Exercise(
            id: "detection.hide-and-seek.clap",
            levelId: "listening.detection",
            type: .listenAndRespond,
            title: "Spot the Clap",
            summary: "Listen for a clap",                           // TODO(copy)
            collection: "Story Hide & Seek",
            illustration: "ex_hide-and-seek-clap",
            items: [listenItem("clap-1", sound: "clap"), listenItem("clap-2", sound: "clap-soft")]
        ),
        Exercise(
            id: "detection.hide-and-seek.drumbeat",
            levelId: "listening.detection",
            type: .listenAndRespond,
            title: "Catch the Drumbeat",
            summary: "Listen for the drum",                         // TODO(copy)
            collection: "Story Hide & Seek",
            illustration: "ex_hide-and-seek-drumbeat",
            items: [listenItem("drum-1", sound: "drum"), listenItem("drum-2", sound: "drum-soft")]
        )
    ]

    private static let differentiation: [Exercise] = [
        Exercise(
            id: "differentiation.odd-sound-out",
            levelId: "listening.differentiation",
            type: .oddOneOut,
            title: "Odd Sound Out",
            summary: "Which one sounds different?",
            collection: "Which One Sounds Different",
            illustration: "ex_odd-sound-out",
            items: [
                oddOneOutItem("odd-1", prompt: "Which one sounds different?", odd: .leo),
                oddOneOutItem("odd-2", prompt: "Which one sounds different?", odd: .zoe)
            ]
        ),
        Exercise(
            id: "differentiation.loud-or-soft",
            levelId: "listening.differentiation",
            type: .oddOneOut,
            title: "Loud or Soft",
            summary: "Find the softer sound",                       // TODO(copy)
            collection: "Which One Sounds Different",
            illustration: "ex_loud-or-soft",
            items: [oddOneOutItem("loud-1", prompt: "Which one is softer?", odd: .zoe)]   // TODO(copy)
        ),
        Exercise(
            id: "differentiation.high-or-low",
            levelId: "listening.differentiation",
            type: .oddOneOut,
            title: "High or Low",
            summary: "Find the higher sound",                       // TODO(copy)
            collection: "Which One Sounds Different",
            illustration: "ex_high-or-low",
            items: [oddOneOutItem("pitch-1", prompt: "Which one is higher?", odd: .mia)]  // TODO(copy)
        ),
        Exercise(
            id: "differentiation.fast-or-slow",
            levelId: "listening.differentiation",
            type: .oddOneOut,
            title: "Fast or Slow",
            summary: "Find the faster sound",                       // TODO(copy)
            collection: "Which One Sounds Different",
            illustration: "ex_fast-or-slow",
            items: [oddOneOutItem("tempo-1", prompt: "Which one is faster?", odd: .leo)]  // TODO(copy)
        ),
        Exercise(
            id: "differentiation.beat-match",
            levelId: "listening.differentiation",
            type: .oddOneOut,
            title: "Beat Match",
            summary: "Same beat or different?",                     // TODO(copy)
            illustration: "ex_beat-match",
            items: [oddOneOutItem("beat-1", prompt: "Which beat is different?", odd: .zoe)]  // TODO(copy)
        ),
        Exercise(
            id: "differentiation.rhythm-match",
            levelId: "listening.differentiation",
            type: .oddOneOut,
            title: "Rhythm Match",
            summary: "Same rhythm or different?",                   // TODO(copy)
            illustration: "ex_rhythm-match",
            items: [oddOneOutItem("rhythm-1", prompt: "Which rhythm is different?", odd: .mia)]  // TODO(copy)
        ),
        Exercise(
            id: "differentiation.speech-sound-differences",
            levelId: "listening.differentiation",
            type: .oddOneOut,
            title: "Speech Sound Differences",
            summary: "Hear the difference between speech sounds",   // TODO(copy)
            illustration: "ex_speech-sound-differences",
            items: [oddOneOutItem("speech-1", prompt: "Which word is different?", odd: .leo)]  // TODO(copy)
        )
    ]

    private static let identification: [Exercise] = [
        Exercise(
            id: "identification.instruments",
            levelId: "listening.identification",
            type: .pictureChoice,
            title: "Instruments",
            summary: "Which instrument is playing?",                // TODO(copy)
            illustration: "ex_instruments",
            items: [
                pictureItem("instruments-1", answer: "drum", choices: ["drum", "guitar", "piano", "flute"]),
                pictureItem("instruments-2", answer: "piano", choices: ["drum", "guitar", "piano", "flute"])
            ]
        ),
        Exercise(
            id: "identification.animals",
            levelId: "listening.identification",
            type: .pictureChoice,
            title: "Animals",
            summary: "Which animal made that sound?",               // TODO(copy)
            illustration: "ex_animals",
            items: [
                pictureItem("animals-1", answer: "cow", choices: ["cow", "goat", "horse", "sheep"]),
                pictureItem("animals-2", answer: "sheep", choices: ["cow", "goat", "horse", "sheep"])
            ]
        ),
        Exercise(
            id: "identification.nature",
            levelId: "listening.identification",
            type: .pictureChoice,
            title: "Nature",
            summary: "Which sound from nature is it?",              // TODO(copy)
            illustration: "ex_nature",
            items: [
                pictureItem("nature-1", answer: "rain", choices: ["rain", "thunder", "wind", "birds"])   // TODO(copy)
            ]
        ),
        Exercise(
            id: "identification.objects",
            levelId: "listening.identification",
            type: .pictureChoice,
            title: "Objects",
            summary: "Which object made that sound?",               // TODO(copy)
            illustration: "ex_objects",
            items: [
                pictureItem("objects-1", answer: "clock", choices: ["clock", "phone", "car", "bell"])    // TODO(copy)
            ]
        )
    ]
}
