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
            id: "speaking.sentences",
            track: .speaking,
            order: 3,
            title: "Sentences",
            subtitle: "Read along and tap any word",                // TODO(copy)
            illustration: "level_sentences",
            exerciseIds: ["sentences.sentence-1"]
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

        // Words: listen, say the word once, checked with speech recognition (Figma: 12 · Speech — Words).
        // Each exercise holds 12 words; every practice picks 5 of them at random
        // (WordsPracticeViewModel.wordsPerSession).
        Exercise(
            id: "words.two-letter", levelId: "speaking.words", type: .listenAndRecord,
            title: "2 letter", summary: "Short words to start",                     // TODO(copy)
            illustration: "ex_words-2",
            items: [
                wordItem("Up", sounds: ["U", "P"], hint: "uh · p → up"),
                wordItem("Go", sounds: ["G", "O"], hint: "g · oh → go"),
                wordItem("No", sounds: ["N", "O"], hint: "n · oh → no", accepted: ["no", "know"]),
                wordItem("Me", sounds: ["M", "E"], hint: "m · ee → me"),
                wordItem("We", sounds: ["W", "E"], hint: "w · ee → we", accepted: ["we", "wee"]),
                wordItem("Hi", sounds: ["H", "I"], hint: "h · eye → hi", accepted: ["hi", "high"]),
                wordItem("Be", sounds: ["B", "E"], hint: "b · ee → be", accepted: ["be", "bee"]),
                wordItem("In", sounds: ["I", "N"], hint: "i · n → in", accepted: ["in", "inn"]),
                wordItem("On", sounds: ["O", "N"], hint: "o · n → on"),
                wordItem("At", sounds: ["A", "T"], hint: "a · t → at"),
                wordItem("It", sounds: ["I", "T"], hint: "i · t → it"),
                wordItem("Is", sounds: ["I", "S"], hint: "i · z → is")
            ]
        ),
        Exercise(
            id: "words.three-letter", levelId: "speaking.words", type: .listenAndRecord,
            title: "3 letter", summary: "Words like Sun",                           // TODO(copy)
            illustration: "ex_words-3",
            items: [
                wordItem("Sun", sounds: ["S", "U", "N"], hint: "sss · uh · nnn → sun", accepted: ["sun", "son"]),
                wordItem("Cat", sounds: ["C", "A", "T"], hint: "k · a · t → cat"),
                wordItem("Dog", sounds: ["D", "O", "G"], hint: "d · o · g → dog"),
                wordItem("Hat", sounds: ["H", "A", "T"], hint: "h · a · t → hat"),
                wordItem("Bus", sounds: ["B", "U", "S"], hint: "b · uh · sss → bus"),
                wordItem("Cup", sounds: ["C", "U", "P"], hint: "k · uh · p → cup"),
                wordItem("Pig", sounds: ["P", "I", "G"], hint: "p · i · g → pig"),
                wordItem("Bed", sounds: ["B", "E", "D"], hint: "b · e · d → bed"),
                wordItem("Red", sounds: ["R", "E", "D"], hint: "r · e · d → red", accepted: ["red", "read"]),
                wordItem("Box", sounds: ["B", "O", "X"], hint: "b · o · ks → box"),
                wordItem("Fan", sounds: ["F", "A", "N"], hint: "f · a · n → fan"),
                wordItem("Map", sounds: ["M", "A", "P"], hint: "m · a · p → map")
            ]
        ),
        Exercise(
            id: "words.four-letter", levelId: "speaking.words", type: .listenAndRecord,
            title: "4 letter", summary: "Words like Ball",                          // TODO(copy)
            illustration: "ex_words-4",
            items: [
                wordItem("Ball", sounds: ["B", "A", "LL"], hint: "b · aw · l → ball"),
                wordItem("Fish", sounds: ["F", "I", "SH"], hint: "f · i · sh → fish"),
                wordItem("Duck", sounds: ["D", "U", "CK"], hint: "d · uh · k → duck"),
                wordItem("Milk", sounds: ["M", "I", "L", "K"], hint: "m · i · l · k → milk"),
                wordItem("Frog", sounds: ["F", "R", "O", "G"], hint: "f · r · o · g → frog"),
                wordItem("Book", sounds: ["B", "OO", "K"], hint: "b · oo · k → book"),
                wordItem("Cake", sounds: ["C", "A", "KE"], hint: "k · ay · k → cake"),
                wordItem("Tree", sounds: ["T", "R", "EE"], hint: "t · r · ee → tree"),
                wordItem("Bird", sounds: ["B", "IR", "D"], hint: "b · er · d → bird"),
                wordItem("Lion", sounds: ["L", "I", "ON"], hint: "l · eye · un → lion"),
                wordItem("Moon", sounds: ["M", "OO", "N"], hint: "m · oo · n → moon"),
                wordItem("Star", sounds: ["S", "T", "AR"], hint: "s · t · ar → star")
            ]
        ),
        Exercise(
            id: "words.five-plus-letter", levelId: "speaking.words", type: .listenAndRecord,
            title: "5 letter & more", summary: "Longer words",                      // TODO(copy)
            illustration: "ex_words-5",
            items: [
                wordItem("Apple", sounds: ["A", "PP", "LE"], hint: "a · p · ul → apple"),
                wordItem("Tiger", sounds: ["T", "I", "G", "ER"], hint: "t · eye · g · er → tiger"),
                wordItem("Water", sounds: ["W", "A", "T", "ER"], hint: "w · aw · t · er → water"),
                wordItem("House", sounds: ["H", "OU", "SE"], hint: "h · ow · s → house"),
                wordItem("Happy", sounds: ["H", "A", "PP", "Y"], hint: "h · a · p · ee → happy"),
                wordItem("Pencil", sounds: ["P", "E", "N", "C", "IL"], hint: "p · e · n · s · ul → pencil"),
                wordItem("Banana", sounds: ["B", "A", "N", "A", "N", "A"], hint: "b · uh · n · ah · n · uh → banana"),
                wordItem("Rabbit", sounds: ["R", "A", "BB", "I", "T"], hint: "r · a · b · i · t → rabbit"),
                wordItem("Flower", sounds: ["F", "L", "OW", "ER"], hint: "f · l · ow · er → flower", accepted: ["flower", "flour"]),
                wordItem("Monkey", sounds: ["M", "O", "N", "K", "EY"], hint: "m · uh · n · k · ee → monkey"),
                wordItem("Orange", sounds: ["OR", "A", "N", "GE"], hint: "or · i · n · j → orange"),
                wordItem("Window", sounds: ["W", "I", "N", "D", "OW"], hint: "w · i · n · d · oh → window")
            ]
        ),

        // Sentences: read along, tap a word to hear it
        Exercise(
            id: "sentences.sentence-1", levelId: "speaking.sentences", type: .readAlong,
            title: "Sentence 1", summary: "Read along, tap a word to hear it",     // TODO(copy)
            illustration: "ex_sentence-1",
            repetitions: 1,
            items: [
                ExerciseItem(
                    id: "sentence-1",
                    audio: "snd_sentence-1",
                    image: "img_sentence-1",
                    text: "TODO(copy) sentence text from PRECODING"
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

    // MARK: - Builders

    /// A word to say, with its sound chips ("S", "U", "N") and how-to-say-it hint.
    /// `accepted` lists what counts as said right; it defaults to the word itself.
    private static func wordItem(_ word: String, sounds: [String], hint: String, accepted: [String]? = nil) -> ExerciseItem {
        let id = word.lowercased()
        return ExerciseItem(
            id: "word-\(id)",
            prompt: "Listen, then say the word",
            audio: "snd_word-\(id)",
            image: "img_word-\(id)",
            text: word,
            options: sounds.enumerated().map { Option(id: "\(id)-\($0.offset)", label: $0.element) },
            hint: hint,
            acceptedAnswers: accepted ?? [id]
        )
    }
}
