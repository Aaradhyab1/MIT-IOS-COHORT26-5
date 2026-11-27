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
            subtitle: "Say words beat by beat",                     // TODO(copy)
            illustration: "level_words",
            exerciseIds: ["words.one-syllable", "words.two-syllable", "words.three-syllable", "words.four-plus-syllable"]
        ),
        Level(
            id: "speaking.sentences",
            track: .speaking,
            order: 3,
            title: "Sentences",
            subtitle: "Read along and tap any word",                // TODO(copy)
            illustration: "level_sentences",
            exerciseIds: [
                "sentences.simple-phrases",
                "sentences.short-sentences",
                "sentences.combined-sentences",
                "sentences.paragraphs"
            ]
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
        // Grouped by syllables (beats): 1, 2, 3, then 4 or more. Each exercise holds 12 words;
        // every practice picks 5 of them at random (WordsPracticeViewModel.wordsPerSession).
        // Multi-syllable words are split into their syllables; one-syllable words into
        // first sound + the rest, so pronunciation help always has parts to say.
        Exercise(
            id: "words.one-syllable", levelId: "speaking.words", type: .listenAndRecord,
            title: "1 syllable", summary: "One beat, like Sun",                     // TODO(copy)
            illustration: "img_1_syllable",
            items: [
                wordItem("Sun", parts: [("S", "s"), ("UN", "ʌn")], accepted: ["sun", "son"]),
                wordItem("Cat", parts: [("C", "k"), ("AT", "æt")]),
                wordItem("Dog", parts: [("D", "d"), ("OG", "ɔɡ")]),
                wordItem("Ball", parts: [("B", "b"), ("ALL", "ɔl")]),
                wordItem("Fish", parts: [("F", "f"), ("ISH", "ɪʃ")]),
                wordItem("Duck", parts: [("D", "d"), ("UCK", "ʌk")]),
                wordItem("Milk", parts: [("M", "m"), ("ILK", "ɪlk")]),
                wordItem("Frog", parts: [("FR", "fɹ"), ("OG", "ɑɡ")]),
                wordItem("Book", parts: [("B", "b"), ("OOK", "ʊk")]),
                wordItem("Cake", parts: [("C", "k"), ("AKE", "eɪk")]),
                wordItem("Tree", parts: [("TR", "tɹ"), ("EE", "i")]),
                wordItem("Star", parts: [("ST", "st"), ("AR", "ɑɹ")])
            ]
        ),
        Exercise(
            id: "words.two-syllable", levelId: "speaking.words", type: .listenAndRecord,
            title: "2 syllables", summary: "Two beats, like Ap-ple",                // TODO(copy)
            illustration: "img_2_syllable",
            items: [
                wordItem("Apple", parts: [("AP", "æp"), ("PLE", "pəl")]),
                wordItem("Tiger", parts: [("TI", "taɪ"), ("GER", "ɡɚ")]),
                wordItem("Water", parts: [("WA", "wɔ"), ("TER", "tɚ")]),
                wordItem("Happy", parts: [("HAP", "hæp"), ("PY", "pi")]),
                wordItem("Pencil", parts: [("PEN", "pɛn"), ("CIL", "səl")]),
                wordItem("Rabbit", parts: [("RAB", "ɹæb"), ("BIT", "bɪt")]),
                wordItem("Flower", parts: [("FLOW", "flaʊ"), ("ER", "ɚ")], accepted: ["flower", "flour"]),
                wordItem("Monkey", parts: [("MON", "mʌŋ"), ("KEY", "ki")]),
                wordItem("Window", parts: [("WIN", "wɪn"), ("DOW", "doʊ")]),
                wordItem("Baby", parts: [("BA", "beɪ"), ("BY", "bi")]),
                wordItem("Lion", parts: [("LI", "laɪ"), ("ON", "ən")]),
                wordItem("Orange", parts: [("OR", "ɔɹ"), ("ANGE", "ɪndʒ")])
            ]
        ),
        Exercise(
            id: "words.three-syllable", levelId: "speaking.words", type: .listenAndRecord,
            title: "3 syllables", summary: "Three beats, like Ba-na-na",            // TODO(copy)
            illustration: "img_3_syllable",
            items: [
                wordItem("Banana", parts: [("BA", "bə"), ("NA", "næ"), ("NA", "nə")]),
                wordItem("Elephant", parts: [("EL", "ɛl"), ("E", "ə"), ("PHANT", "fənt")]),
                wordItem("Butterfly", parts: [("BUT", "bʌ"), ("TER", "tɚ"), ("FLY", "flaɪ")]),
                wordItem("Dinosaur", parts: [("DI", "daɪ"), ("NO", "nə"), ("SAUR", "sɔɹ")]),
                wordItem("Tomato", parts: [("TO", "tə"), ("MA", "meɪ"), ("TO", "toʊ")]),
                wordItem("Kangaroo", parts: [("KAN", "kæŋ"), ("GA", "ɡə"), ("ROO", "ɹu")]),
                wordItem("Octopus", parts: [("OC", "ɑk"), ("TO", "tə"), ("PUS", "pʊs")]),
                wordItem("Umbrella", parts: [("UM", "ʌm"), ("BREL", "bɹɛ"), ("LA", "lə")]),
                wordItem("Bicycle", parts: [("BI", "baɪ"), ("CY", "sɪ"), ("CLE", "kəl")]),
                wordItem("Pineapple", parts: [("PINE", "paɪn"), ("AP", "æ"), ("PLE", "pəl")]),
                wordItem("Strawberry", parts: [("STRAW", "stɹɔ"), ("BER", "bɛ"), ("RY", "ɹi")]),
                wordItem("Computer", parts: [("COM", "kəm"), ("PU", "pju"), ("TER", "tɚ")])
            ]
        ),
        Exercise(
            id: "words.four-plus-syllable", levelId: "speaking.words", type: .listenAndRecord,
            title: "4 syllables & more", summary: "Long words, like Wa-ter-mel-on",  // TODO(copy)
            illustration: "img_4_or_more_syllable",
            items: [
                wordItem("Watermelon", parts: [("WA", "wɔ"), ("TER", "tɚ"), ("MEL", "mɛ"), ("ON", "lən")]),
                wordItem("Caterpillar", parts: [("CAT", "kæ"), ("ER", "tɚ"), ("PIL", "pɪ"), ("LAR", "lɚ")]),
                wordItem("Alligator", parts: [("AL", "æ"), ("LI", "lə"), ("GA", "ɡeɪ"), ("TOR", "tɚ")]),
                wordItem("Helicopter", parts: [("HEL", "hɛ"), ("I", "lə"), ("COP", "kɑp"), ("TER", "tɚ")]),
                wordItem("Avocado", parts: [("AV", "æ"), ("O", "və"), ("CA", "kɑ"), ("DO", "doʊ")]),
                wordItem("Macaroni", parts: [("MAC", "mæ"), ("A", "kə"), ("RO", "ɹoʊ"), ("NI", "ni")]),
                wordItem("Television", parts: [("TEL", "tɛ"), ("E", "lə"), ("VI", "vɪ"), ("SION", "ʒən")]),
                wordItem("Calculator", parts: [("CAL", "kæl"), ("CU", "kjə"), ("LA", "leɪ"), ("TOR", "tɚ")]),
                wordItem("Harmonica", parts: [("HAR", "hɑɹ"), ("MON", "mɑ"), ("I", "nɪ"), ("CA", "kə")]),
                wordItem("Escalator", parts: [("ES", "ɛs"), ("CA", "kə"), ("LA", "leɪ"), ("TOR", "tɚ")]),
                wordItem("Activity", parts: [("AC", "æk"), ("TIV", "tɪ"), ("I", "vɪ"), ("TY", "ti")]),
                wordItem("Hippopotamus", parts: [("HIP", "hɪ"), ("PO", "pə"), ("POT", "pɑ"), ("A", "tə"), ("MUS", "məs")])
            ]
        ),

        // Sentences: read aloud while the words light up, tap a word to hear it.
        // Each item is one passage; its options give syllables for longer words.
        // Grouped by how the language is built, not by word count, and each category
        // gets a little harder from its first passage to its last.

        // Simple phrases: 3–5 words that are not a full sentence (no verb).
        // Everyday expressions → a thing with a describing word → a longer naming phrase.
        Exercise(
            id: "sentences.simple-phrases", levelId: "speaking.sentences", type: .readAlong,
            title: "Simple Phrases", summary: "Read short groups of words",
            durationMinutes: 2,
            illustration: "ex_sentences-simple-phrases",
            repetitions: 5,
            items: [
                readingItem("phrase-good-night", "Good night, Grandma", syllables: ["grandma": "GRAND-ma"]),
                readingItem("phrase-rainy-day", "A rainy day", syllables: ["rainy": "RAIN-y"]),
                readingItem("phrase-pencil-box", "My new pencil box", syllables: ["pencil": "PEN-cil"]),
                readingItem("phrase-teddy-bear", "My favourite teddy bear", syllables: ["favourite": "FA-vour-ite", "teddy": "TED-dy"]),
                readingItem("phrase-cold-water", "A glass of cold water", syllables: ["water": "WA-ter"])
            ]
        ),

        // Short sentences: one complete idea, simple words.
        // A feeling → describing something → a plan with a place and a time.
        Exercise(
            id: "sentences.short-sentences", levelId: "speaking.sentences", type: .readAlong,
            title: "Short Sentences", summary: "Read a sentence with one idea",
            durationMinutes: 1,
            illustration: "ex_sentences-short-sentences",
            repetitions: 3,
            items: [
                readingItem("short-hungry", "I am hungry.", syllables: ["hungry": "HUN-gry"]),
                readingItem("short-shoes", "My shoes are too small."),
                readingItem("short-park", "We are going to the park today.", syllables: ["going": "GO-ing", "today": "to-DAY"])
            ]
        ),

        // Combined sentences: two ideas joined by and, but, or, so.
        // A "but" sentence → a longer "so" sentence.
        Exercise(
            id: "sentences.combined-sentences", levelId: "speaking.sentences", type: .readAlong,
            title: "Combined Sentences", summary: "Join two ideas with and, but, or, so",
            durationMinutes: 1,
            illustration: "ex_sentences-combined-sentences",
            repetitions: 2,
            items: [
                readingItem("combined-play-rain", "I want to play, but it is raining.", syllables: ["raining": "RAIN-ing"]),
                readingItem("combined-cold-jacket", "I am cold, so I will wear my jacket.", syllables: ["jacket": "JACK-et"])
            ]
        ),

        // Paragraphs: 3–5 connected sentences about one topic.
        // A daily routine in three sentences.
        Exercise(
            id: "sentences.paragraphs", levelId: "speaking.sentences", type: .readAlong,
            title: "Paragraphs", summary: "Read a few sentences about one topic",
            durationMinutes: 2,
            illustration: "ex_sentences-paragraphs",
            repetitions: 1,
            items: [
                readingItem(
                    "paragraph-morning",
                    "Every morning, I wake up early. I brush my teeth and eat my breakfast. Then Mom walks me to school.",
                    syllables: ["every": "EV-ery", "morning": "MOR-ning", "early": "EAR-ly", "breakfast": "BREAK-fast"]
                )
            ]
        ),

        // Conversation: a real-life role-play (Figma: kalp › 14 · Speech — Conversation).
        // Each turn is a question with 2–3 choices, so there is one definite answer to check.
        // An answer that is not one of the choices makes the shopkeeper ask again
        // ("Sorry, you can only choose …", built by ConversationTurn.retryLine).
        // `image` / Option `image` are empty picture slots until those assets are added.
        Exercise(
            id: "conversation.ice-cream-shop", levelId: "speaking.conversation", type: .conversation,
            title: "Ice Cream Shop", summary: "Order your favourite ice cream",     // TODO(copy)
            illustration: "ex_ice-cream-shop",
            repetitions: 1,
            items: [
                conversationTurn(
                    "turn-flavour",
                    question: "Hi there! What ice cream would you like today? We have chocolate, vanilla or strawberry.",
                    choices: ["Chocolate", "Vanilla", "Strawberry"],
                    confirmation: "{choice}, yummy!"
                ),
                conversationTurn(
                    "turn-cup-or-cone",
                    question: "Yummy! Would you like it in a cup or a cone?",
                    choices: ["Cup", "Cone"],
                    confirmation: "A {choice}, coming right up!"
                ),
                conversationTurn(
                    "turn-topping",
                    question: "Would you like sprinkles or a cherry on top?",
                    choices: ["Sprinkles", "Cherry"],
                    confirmation: "{choice} on top, lovely!"
                )
            ]
        )
    ]

    // MARK: - Builders

    /// A passage to read aloud. `syllables` tells the pronunciation sheet how to say
    /// longer words ("morning" → "MOR-ning"); other words show in capitals ("DOG").
    private static func readingItem(_ id: String, _ text: String, syllables: [String: String] = [:]) -> ExerciseItem {
        ExerciseItem(
            id: id,
            prompt: "Read it aloud",
            text: text,
            options: syllables.sorted { $0.key < $1.key }.map { Option(id: $0.key, label: $0.value) }
        )
    }

    /// A conversation turn: the shopkeeper's question, the choices the child can say, and
    /// how the shopkeeper confirms an answer ("{choice}" is replaced by it).
    /// Picture slots: "img_conversation_shopkeeper" for the shopkeeper and
    /// "img_choice_<choice>" (e.g. "img_choice_chocolate") for each choice.
    private static func conversationTurn(_ id: String, question: String, choices: [String],
                                         confirmation: String) -> ExerciseItem {
        ExerciseItem(
            id: id,
            prompt: "Tell the shopkeeper what you would like.",
            image: "img_conversation_shopkeeper",
            text: question,
            speaker: .mia,
            options: choices.map { choice in
                let key = choice.lowercased()
                return Option(id: "\(id)-\(key)", label: choice, image: "img_choice_\(key)")
            },
            hint: confirmation,
            acceptedAnswers: choices.map { $0.lowercased() }
        )
    }

    /// A word to say, broken into parts for pronunciation help.
    ///
    /// Each part is (chip text, IPA sound): one per syllable for longer words ("AP" + "PLE"),
    /// first sound + the rest for one-syllable words ("S" + "UN"). The IPA makes the voice say the
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
