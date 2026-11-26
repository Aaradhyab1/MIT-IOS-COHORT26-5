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
                wordItem("Up", parts: [("U", "ʌ"), ("P", "p")]),
                wordItem("Go", parts: [("G", "ɡ"), ("O", "oʊ")]),
                wordItem("No", parts: [("N", "n"), ("O", "oʊ")], accepted: ["no", "know"]),
                wordItem("Me", parts: [("M", "m"), ("E", "i")]),
                wordItem("We", parts: [("W", "w"), ("E", "i")], accepted: ["we", "wee"]),
                wordItem("Hi", parts: [("H", "h"), ("I", "aɪ")], accepted: ["hi", "high"]),
                wordItem("Be", parts: [("B", "b"), ("E", "i")], accepted: ["be", "bee"]),
                wordItem("In", parts: [("I", "ɪ"), ("N", "n")], accepted: ["in", "inn"]),
                wordItem("On", parts: [("O", "ɑ"), ("N", "n")]),
                wordItem("At", parts: [("A", "æ"), ("T", "t")]),
                wordItem("It", parts: [("I", "ɪ"), ("T", "t")]),
                wordItem("Is", parts: [("I", "ɪ"), ("S", "z")])
            ]
        ),
        Exercise(
            id: "words.three-letter", levelId: "speaking.words", type: .listenAndRecord,
            title: "3 letter", summary: "Words like Sun",                           // TODO(copy)
            illustration: "ex_words-3",
            items: [
                wordItem("Sun", parts: [("S", "s"), ("UN", "ʌn")], accepted: ["sun", "son"]),
                wordItem("Cat", parts: [("C", "k"), ("AT", "æt")]),
                wordItem("Dog", parts: [("D", "d"), ("OG", "ɔɡ")]),
                wordItem("Hat", parts: [("H", "h"), ("AT", "æt")]),
                wordItem("Bus", parts: [("B", "b"), ("US", "ʌs")]),
                wordItem("Cup", parts: [("C", "k"), ("UP", "ʌp")]),
                wordItem("Pig", parts: [("P", "p"), ("IG", "ɪɡ")]),
                wordItem("Bed", parts: [("B", "b"), ("ED", "ɛd")]),
                wordItem("Red", parts: [("R", "ɹ"), ("ED", "ɛd")], accepted: ["red", "read"]),
                wordItem("Box", parts: [("B", "b"), ("OX", "ɑks")]),
                wordItem("Fan", parts: [("F", "f"), ("AN", "æn")]),
                wordItem("Map", parts: [("M", "m"), ("AP", "æp")])
            ]
        ),
        Exercise(
            id: "words.four-letter", levelId: "speaking.words", type: .listenAndRecord,
            title: "4 letter", summary: "Words like Ball",                          // TODO(copy)
            illustration: "ex_words-4",
            items: [
                wordItem("Ball", parts: [("B", "b"), ("ALL", "ɔl")]),
                wordItem("Fish", parts: [("F", "f"), ("ISH", "ɪʃ")]),
                wordItem("Duck", parts: [("D", "d"), ("UCK", "ʌk")]),
                wordItem("Milk", parts: [("M", "m"), ("ILK", "ɪlk")]),
                wordItem("Frog", parts: [("FR", "fɹ"), ("OG", "ɑɡ")]),
                wordItem("Book", parts: [("B", "b"), ("OOK", "ʊk")]),
                wordItem("Cake", parts: [("C", "k"), ("AKE", "eɪk")]),
                wordItem("Tree", parts: [("TR", "tɹ"), ("EE", "i")]),
                wordItem("Bird", parts: [("B", "b"), ("IRD", "ɝd")]),
                wordItem("Lion", parts: [("LI", "laɪ"), ("ON", "ən")]),
                wordItem("Moon", parts: [("M", "m"), ("OON", "un")]),
                wordItem("Star", parts: [("ST", "st"), ("AR", "ɑɹ")])
            ]
        ),
        Exercise(
            id: "words.five-plus-letter", levelId: "speaking.words", type: .listenAndRecord,
            title: "5 letter & more", summary: "Longer words",                      // TODO(copy)
            illustration: "ex_words-5",
            items: [
                wordItem("Apple", parts: [("AP", "æp"), ("PLE", "pəl")]),
                wordItem("Tiger", parts: [("TI", "taɪ"), ("GER", "ɡɚ")]),
                wordItem("Water", parts: [("WA", "wɔ"), ("TER", "tɚ")]),
                wordItem("House", parts: [("H", "h"), ("OUSE", "aʊs")]),
                wordItem("Happy", parts: [("HAP", "hæp"), ("PY", "pi")]),
                wordItem("Pencil", parts: [("PEN", "pɛn"), ("CIL", "səl")]),
                wordItem("Banana", parts: [("BA", "bə"), ("NA", "næ"), ("NA", "nə")]),
                wordItem("Rabbit", parts: [("RAB", "ɹæb"), ("BIT", "bɪt")]),
                wordItem("Flower", parts: [("FLOW", "flaʊ"), ("ER", "ɚ")], accepted: ["flower", "flour"]),
                wordItem("Monkey", parts: [("MON", "mʌŋ"), ("KEY", "ki")]),
                wordItem("Orange", parts: [("OR", "ɔɹ"), ("ANGE", "ɪndʒ")]),
                wordItem("Window", parts: [("WIN", "wɪn"), ("DOW", "doʊ")])
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

    /// A word to say, broken into parts for pronunciation help.
    ///
    /// Each part is (chip text, IPA sound): syllables for longer words ("AP" + "PLE"),
    /// first sound + the rest for short words ("S" + "UN"). The IPA makes the voice say the
    /// sound itself ("sss"), not the letter name ("ess"). The hint shown to the parent,
    /// e.g. "s · un → sun", is built from the chips.
    /// `accepted` lists what counts as said right; it defaults to the word itself.
    private static func wordItem(_ word: String, parts: [(chip: String, ipa: String)], accepted: [String]? = nil) -> ExerciseItem {
        let id = word.lowercased()
        let hint = parts.map { $0.chip.lowercased() }.joined(separator: " · ") + " → " + id
        return ExerciseItem(
            id: "word-\(id)",
            prompt: "Listen, then say the word",
            audio: "snd_word-\(id)",
            image: "img_word-\(id)",
            text: word,
            options: parts.enumerated().map { index, part in
                Option(id: "\(id)-\(index)", label: part.chip, pronunciation: part.ipa)
            },
            hint: hint,
            acceptedAnswers: accepted ?? [id]
        )
    }
}
