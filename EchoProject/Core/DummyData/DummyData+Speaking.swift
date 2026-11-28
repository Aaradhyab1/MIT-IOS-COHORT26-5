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
        // Grouped by syllables (beats): 1, 2, 3, then 4 or more, each list shortest word first.
        // Each exercise holds 12 words;
        // every practice picks 5 of them at random (WordsPracticeViewModel.wordsPerSession).
        // Pronunciation help splits every word by syllable: "dog" stays one part,
        // "ap · ple" is two, "ba · na · na" is three.
        Exercise(
            id: "words.one-syllable", levelId: "speaking.words", type: .listenAndRecord,
            title: "1 syllable", summary: "One beat, like Sun",                     // TODO(copy)
            illustration: "img_1_syllable",
            items: [
                wordItem("Sun", parts: [("SUN", "sun")], accepted: ["sun", "son"]),
                wordItem("Cat", parts: [("CAT", "cat")]),
                wordItem("Dog", parts: [("DOG", "dog")]),
                wordItem("Fish", parts: [("FISH", "fish")]),
                wordItem("Duck", parts: [("DUCK", "duck")]),
                wordItem("Book", parts: [("BOOK", "book")]),
                wordItem("Cake", parts: [("CAKE", "cake")]),
                wordItem("Ball", parts: [("BALL", "ball")]),
                wordItem("Milk", parts: [("MILK", "milk")]),
                wordItem("Tree", parts: [("TREE", "tree")]),
                wordItem("Frog", parts: [("FROG", "frog")]),
                wordItem("Star", parts: [("STAR", "star")])
            ]
        ),
        Exercise(
            id: "words.two-syllable", levelId: "speaking.words", type: .listenAndRecord,
            title: "2 syllables", summary: "Two beats, like Ap-ple",                // TODO(copy)
            illustration: "img_2_syllable",
            items: [
                wordItem("Baby", parts: [("BA", "bay"), ("BY", "bee")]),
                wordItem("Lion", parts: [("LI", "lie"), ("ON", "un")]),
                wordItem("Apple", parts: [("AP", "ap"), ("PLE", "pull")]),
                wordItem("Tiger", parts: [("TI", "tie"), ("GER", "gur")]),
                wordItem("Water", parts: [("WA", "wah"), ("TER", "ter")]),
                wordItem("Happy", parts: [("HA", "ha"), ("PPY", "pee")]),
                wordItem("Monkey", parts: [("MON", "mun"), ("KEY", "key")]),
                wordItem("Window", parts: [("WIN", "win"), ("DOW", "doe")]),
                wordItem("Pencil", parts: [("PEN", "pen"), ("CIL", "sull")]),
                wordItem("Rabbit", parts: [("RA", "rah"), ("BBIT", "bit")]),
                wordItem("Flower", parts: [("FLOW", "flaow"), ("ER", "er")], accepted: ["flower", "flour"]),
                wordItem("Orange", parts: [("OR", "or"), ("ANGE", "inj")])
            ]
        ),
        Exercise(
            id: "words.three-syllable", levelId: "speaking.words", type: .listenAndRecord,
            title: "3 syllables", summary: "Three beats, like Ba-na-na",            // TODO(copy)
            illustration: "img_3_syllable",
            items: [
                wordItem("Banana", parts: [("BA", "buh"), ("NA", "nan"), ("NA", "nuh")]),
                wordItem("Tomato", parts: [("TO", "tuh"), ("MA", "may"), ("TO", "toe")]),
                wordItem("Octopus", parts: [("OC", "ock"), ("TO", "tuh"), ("PUS", "puss")]),
                wordItem("Bicycle", parts: [("BI", "bye"), ("CY", "sih"), ("CLE", "kul")]),
                wordItem("Dinosaur", parts: [("DI", "die"), ("NO", "nuh"), ("SAUR", "sore")]),
                wordItem("Elephant", parts: [("E", "eh"), ("LE", "luh"), ("PHANT", "funt")]),
                wordItem("Kangaroo", parts: [("KAN", "kang"), ("GA", "guh"), ("ROO", "roo")]),
                wordItem("Umbrella", parts: [("UM", "um"), ("BREL", "brel"), ("LA", "luh")]),
                wordItem("Computer", parts: [("COM", "kum"), ("PU", "pew"), ("TER", "ter")]),
                wordItem("Pineapple", parts: [("PINE", "pine"), ("AP", "ap"), ("PLE", "pull")]),
                wordItem("Butterfly", parts: [("BU", "buh"), ("TTER", "ter"), ("FLY", "fly")]),
                wordItem("Strawberry", parts: [("STRAW", "straw"), ("BE", "beh"), ("RRY", "ree")])
            ]
        ),
        Exercise(
            id: "words.four-plus-syllable", levelId: "speaking.words", type: .listenAndRecord,
            title: "4 syllables & more", summary: "Long words, like Wa-ter-mel-on",  // TODO(copy)
            illustration: "img_4_or_more_syllable",
            items: [
                wordItem("Avocado", parts: [("A", "ah"), ("VO", "voh"), ("CA", "kah"), ("DO", "doe")]),
                wordItem("Activity", parts: [("AC", "ack"), ("TI", "tih"), ("VI", "vih"), ("TY", "tee")]),
                wordItem("Macaroni", parts: [("MA", "mah"), ("CA", "kuh"), ("RO", "roe"), ("NI", "nee")]),
                wordItem("Alligator", parts: [("A", "ah"), ("LLI", "lih"), ("GA", "gay"), ("TOR", "ter")]),
                wordItem("Escalator", parts: [("ES", "ess"), ("CA", "kuh"), ("LA", "lay"), ("TOR", "ter")]),
                wordItem("Harmonica", parts: [("HAR", "har"), ("MO", "mah"), ("NI", "nih"), ("CA", "kuh")]),
                wordItem("Watermelon", parts: [("WA", "wah"), ("TER", "ter"), ("ME", "meh"), ("LON", "lun")]),
                wordItem("Helicopter", parts: [("HE", "heh"), ("LI", "lih"), ("COP", "kop"), ("TER", "ter")]),
                wordItem("Calculator", parts: [("CAL", "kal"), ("CU", "kyuh"), ("LA", "lay"), ("TOR", "ter")]),
                wordItem("Television", parts: [("TE", "teh"), ("LE", "luh"), ("VI", "vih"), ("SION", "zhun")]),
                wordItem("Caterpillar", parts: [("CA", "ka"), ("TER", "ter"), ("PI", "pih"), ("LLAR", "ler")]),
                wordItem("Hippopotamus", parts: [("HI", "hih"), ("PPO", "poh"), ("PO", "pah"), ("TA", "tuh"), ("MUS", "muss")])
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
            illustration: "img_mia_serving_ice_cream",   // Mia the shopkeeper, new art style
            repetitions: 1,
            items: [
                conversationTurn(
                    "turn-flavour",
                    question: "Hi there! What ice cream would you like today? We have chocolate, vanilla or strawberry.",
                    choices: ["Chocolate", "Vanilla", "Strawberry"],
                    background: "img_bg_conversation_flavour",
                    confirmation: "{choice}, yummy!"
                ),
                conversationTurn(
                    "turn-cup-or-cone",
                    question: "Yummy! Would you like it in a cup or a cone?",
                    choices: ["Cup", "Cone"],
                    background: "img_bg_conversation_cup_cone",
                    confirmation: "A {choice}, coming right up!"
                ),
                conversationTurn(
                    "turn-topping",
                    question: "Would you like sprinkles or a cherry on top?",
                    choices: ["Sprinkles", "Cherry"],
                    background: "img_bg_conversation_topping",
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
    /// `background` is the full-screen shop for this turn: Mia with the counter showing
    /// what she is asking about (flavours, cup and cone, toppings).
    /// "img_choice_<choice>" (e.g. "img_choice_chocolate") is the picture for each choice.
    private static func conversationTurn(_ id: String, question: String, choices: [String],
                                         background: String, confirmation: String) -> ExerciseItem {
        ExerciseItem(
            id: id,
            prompt: "Tell the shopkeeper what you would like.",
            image: background,
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
    /// Each part is (chip text, how it sounds), one part per syllable: "AP" + "PLE" said
    /// "ap", "pull". A one-syllable word is a single part, said as the word itself ("dog"). The sound is spelled like a word so the voice says it
    /// smoothly. The hint shown to the parent,
    /// e.g. "s · un → sun", is built from the chips.
    /// `accepted` lists what counts as said right; it defaults to the word itself.
    private static func wordItem(_ word: String, parts: [(chip: String, sound: String)], accepted: [String]? = nil) -> ExerciseItem {
        let id = word.lowercased()
        let hint = parts.count > 1
            ? parts.map { $0.chip.lowercased() }.joined(separator: " · ") + " → " + id
            : id
        return ExerciseItem(
            id: "word-\(id)",
            prompt: "Listen, then say the word",
            audio: "snd_word-\(id)",
            image: "img_word-\(id)",
            text: word,
            options: parts.enumerated().map { index, part in
                Option(id: "\(id)-\(index)", label: part.chip, pronunciation: part.sound)
            },
            hint: hint,
            acceptedAnswers: accepted ?? [id]
        )
    }
}
