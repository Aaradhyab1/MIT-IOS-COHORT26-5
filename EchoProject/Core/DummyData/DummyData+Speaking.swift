import Foundation

extension DummyData {

    // MARK: - Levels (the four Speaking sections)

    static let speakingLevels: [Level] = [
        Level(
            id: "speaking.sounds",
            track: .speaking,
            order: 1,
            title: "Sounds",
            subtitle: "Vowels, consonants and syllables",           // TODO(copy)
            illustration: "level_sounds",
            exerciseIds: ["sounds.vowel", "sounds.consonant", "sounds.syllable", "sounds.speech-sound-pattern"]
        ),
        Level(
            id: "speaking.words",
            track: .speaking,
            order: 2,
            title: "Words",
            subtitle: "Say short words clearly",                    // TODO(copy)
            illustration: "level_words",
            exerciseIds: ["words.two-letter", "words.three-letter", "words.four-letter", "words.five-plus-letter"]
        ),
        Level(
            id: "speaking.paragraphs",
            track: .speaking,
            order: 3,
            title: "Paragraphs",
            subtitle: "Read along and tap any word",                // TODO(copy)
            illustration: "level_paragraphs",
            exerciseIds: ["paragraphs.paragraph-1"]
        ),
        Level(
            id: "speaking.conversation",
            track: .speaking,
            order: 4,
            title: "Conversation",
            subtitle: "Practise a real-life chat",                  // TODO(copy)
            illustration: "level_conversation",
            exerciseIds: ["conversation.ice-cream-shop"]
        )
    ]

    // MARK: - Exercises

    static let speakingExercises: [Exercise] = [
        // Sounds: listen, then record 10 times
        Exercise(
            id: "sounds.vowel", levelId: "speaking.sounds", type: .listenAndRecord,
            title: "Vowel", summary: "Say the vowel sound",                         // TODO(copy)
            illustration: "ex_vowel",
            items: [recordItem("vowel-a", text: "a")]                               // TODO(copy)
        ),
        Exercise(
            id: "sounds.consonant", levelId: "speaking.sounds", type: .listenAndRecord,
            title: "Consonant", summary: "Say the consonant sound",                 // TODO(copy)
            illustration: "ex_consonant",
            items: [recordItem("consonant-m", text: "m")]                           // TODO(copy)
        ),
        Exercise(
            id: "sounds.syllable", levelId: "speaking.sounds", type: .listenAndRecord,
            title: "Syllable", summary: "Say the syllable",                         // TODO(copy)
            illustration: "ex_syllable",
            items: [recordItem("syllable-ba", text: "ba")]                          // TODO(copy)
        ),
        Exercise(
            id: "sounds.speech-sound-pattern", levelId: "speaking.sounds", type: .listenAndRecord,
            title: "Speech Sound Pattern", summary: "Copy the sound pattern",       // TODO(copy)
            illustration: "ex_speech-sound-pattern",
            items: [recordItem("pattern-ba-ba", text: "ba ba")]                     // TODO(copy)
        ),

        // Words
        Exercise(
            id: "words.two-letter", levelId: "speaking.words", type: .listenAndRecord,
            title: "2-letter words", summary: "Short words to start",               // TODO(copy)
            illustration: "ex_words-2",
            items: [recordItem("word-up", text: "Up")]                              // TODO(copy)
        ),
        Exercise(
            id: "words.three-letter", levelId: "speaking.words", type: .listenAndRecord,
            title: "3-letter words", summary: "Words like Sun",                     // TODO(copy)
            illustration: "ex_words-3",
            items: [recordItem("word-sun", text: "Sun")]
        ),
        Exercise(
            id: "words.four-letter", levelId: "speaking.words", type: .listenAndRecord,
            title: "4-letter words", summary: "Words like Ball",                    // TODO(copy)
            illustration: "ex_words-4",
            items: [recordItem("word-ball", text: "Ball")]
        ),
        Exercise(
            id: "words.five-plus-letter", levelId: "speaking.words", type: .listenAndRecord,
            title: "5+ letter words", summary: "Longer words",                      // TODO(copy)
            illustration: "ex_words-5",
            items: [recordItem("word-apple", text: "Apple")]                        // TODO(copy)
        ),

        // Paragraphs: tap a word to hear it
        Exercise(
            id: "paragraphs.paragraph-1", levelId: "speaking.paragraphs", type: .readAlong,
            title: "Paragraph 1", summary: "Read along, tap a word to hear it",     // TODO(copy)
            illustration: "ex_paragraph-1",
            repetitions: 1,
            items: [
                ExerciseItem(
                    id: "paragraph-1",
                    audio: "snd_paragraph-1",
                    image: "img_paragraph-1",
                    text: "TODO(copy) paragraph text from PRECODING"
                )
            ]
        ),

        // Conversation: scripted turns, child records each reply
        Exercise(
            id: "conversation.ice-cream-shop", levelId: "speaking.conversation", type: .conversation,
            title: "Ice cream shop", summary: "Order your favourite ice cream",     // TODO(copy)
            illustration: "ex_ice-cream-shop",
            repetitions: 1,
            items: [
                ExerciseItem(id: "turn-1", audio: "snd_turn-1", text: "Hello! What flavour would you like?", speaker: .pip),  // TODO(copy)
                ExerciseItem(id: "turn-2", prompt: "Your turn", text: "I would like chocolate, please."),                     // TODO(copy)
                ExerciseItem(id: "turn-3", audio: "snd_turn-3", text: "Here you go! Enjoy!", speaker: .pip)                   // TODO(copy)
            ]
        )
    ]
}
