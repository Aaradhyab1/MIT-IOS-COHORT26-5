import Foundation

extension DummyData {

    // MARK: - Comprehension exercises (Listening level 4)

    struct MatchPair {
        let id: String
        let who: String
        let did: String
    }

    private static func story(
        _ id: String,
        title: String,
        pages: [String],
        events: [String],
        pairs: [MatchPair]
    ) -> Exercise {
        let pageItems = pages.enumerated().map { index, page in
            ExerciseItem(
                id: "\(id)-page-\(index + 1)",
                audio: "snd_story-\(id)-\(index + 1)",
                image: "img_story-\(id)-\(index + 1)",
                text: page
            )
        }

        let ordering = ExerciseItem(
            id: "\(id)\(StoryItemSuffix.ordering)",
            prompt: "Put the events in order",
            text: "Drag each card into the right number.",
            options: events.enumerated().map { index, event in
                Option(id: "\(id)-event-\(index + 1)", label: event, image: "img_story-\(id)-event-\(index + 1)")
            }
        )

        let matching = ExerciseItem(
            id: "\(id)\(StoryItemSuffix.matching)",
            prompt: "Who did what?",
            text: "Match each character to what they did.",
            options: pairs.map { Option(id: $0.id, label: $0.who, image: "img_match-\($0.id)") }
        )

        let matchingAnswers = ExerciseItem(
            id: "\(id)\(StoryItemSuffix.matchingAnswers)",
            options: pairs.map { Option(id: $0.id, label: $0.did, image: "img_match-\($0.id)-action") }
        )

        return Exercise(
            id: "comprehension.story.\(id)",
            levelId: "listening.comprehension",
            type: .storyPlayer,
            title: title,
            summary: "Listen to the story, then answer",            // TODO(copy)
            collection: "Stories",
            illustration: "ex_story-\(id)",
            items: pageItems + [ordering, matching, matchingAnswers]
        )
    }

    /// Level 4 exercises. Kept in their own file so the Comprehension owner edits
    /// only this file; the level itself is defined in DummyData+Listening.swift.
    static let comprehension: [Exercise] = [
        story(
            "cat-and-bird",
            title: "The cat and the bird",
            pages: [
                """
                One sunny morning, a little blue bird sat on a branch and sang a happy song. \
                Down on the grass, a slow green turtle saw a piece of bread. \
                The turtle said, "Look, bread!" \
                The bird saw the bread too. \
                She flew down and ate the bread. Crunch, crunch, crunch! \
                But a grey cat was hiding behind the tree. \
                The cat chased the bird! \
                The bird flapped her wings as fast as she could. Up, up, up she went. \
                The bird flew away safely, back to her branch. \
                The cat sat down and licked his paw. \
                And the little bird sang her happy song again.
                """
            ],
            events: ["The bird saw the bread.", "The cat chased the bird.", "The bird flew away safely."],
            pairs: [
                MatchPair(id: "bird", who: "Bird", did: "Ate the bread"),
                MatchPair(id: "cat", who: "Cat", did: "Chased the bird"),
                MatchPair(id: "turtle", who: "Turtle", did: "Saw the bread")
            ]
        ),
        story(
            "pip-lost-marble",
            title: "Pip and the lost marble",
            pages: [
                """
                Pip was a little blue bird with a shiny marble. \
                He loved to roll it along the path. Roll, roll, roll! \
                One day, the marble rolled far, far away. \
                Pip looked and looked, but he could not find it. \
                "Oh no! Where is my marble?" said Pip. \
                Pip asked his friends for help. \
                Bunny looked under the bush. Hop, hop! But the marble was not there. \
                Squirrel looked up in the tree. But the marble was not there either. \
                Then Pip saw something shining in the grass. Sparkle, sparkle! \
                Pip found his marble! \
                "Thank you for helping me, friends!" said Pip. \
                And they all played with the marble together.
                """
            ],
            events: ["Pip lost his marble.", "Bunny looked under the bush.", "Pip found his marble."],
            pairs: [
                MatchPair(id: "pip", who: "Pip", did: "Found the marble"),
                MatchPair(id: "bunny", who: "Bunny", did: "Looked under the bush"),
                MatchPair(id: "squirrel", who: "Squirrel", did: "Looked up in the tree")
            ]
        ),
        story(
            "brave-firetruck",
            title: "The brave little firetruck",
            pages: [
                """
                Little Red was a small firetruck with a big heart. \
                One windy day, a little kitten climbed up a tall tree. Up, up, up! \
                But then the kitten could not get down. She was stuck! \
                "Meow! Meow!" cried the kitten. \
                Mama Cat called for help. "Help! My kitten is stuck!" \
                Little Red heard her. Nee-naw, nee-naw! \
                Little Red raced to the tree as fast as she could. \
                She raised her long ladder, higher and higher. \
                The kitten climbed down the ladder, step by step. \
                Mama Cat gave her kitten a big, warm hug. \
                "Thank you, Little Red!" \
                Little Red was small, but she was very brave.
                """
            ],
            events: ["The kitten got stuck in the tree.", "Little Red raced to help.", "The kitten climbed down the ladder."],
            pairs: [
                MatchPair(id: "kitten", who: "Kitten", did: "Got stuck in the tree"),
                MatchPair(id: "mama-cat", who: "Mama Cat", did: "Called for help"),
                MatchPair(id: "firetruck", who: "Little Red", did: "Raised the ladder")
            ]
        ),
        story(
            "olivia-starry-sky",
            title: "Olivia's starry sky",
            pages: [
                """
                It was bedtime, but Olivia could not sleep. \
                She looked out of her window at the dark night sky. \
                A friendly owl sat on a branch. \
                "Hoo, hoo! Let's count the stars," said Owl. \
                One, two, three twinkly stars! \
                Olivia and Owl counted the stars together. \
                The big round Moon smiled and sang a soft lullaby. La, la, la. \
                Then, whoosh! A shooting star zoomed across the sky. \
                Olivia closed her eyes and made a wish. \
                She gave a big yawn and snuggled into bed. \
                Goodnight, stars. Goodnight, Owl. Goodnight, Moon.
                """
            ],
            events: ["Olivia could not sleep.", "Olivia and Owl counted the stars.", "Olivia made a wish."],
            pairs: [
                MatchPair(id: "olivia", who: "Olivia", did: "Made a wish"),
                MatchPair(id: "owl", who: "Owl", did: "Counted the stars"),
                MatchPair(id: "moon", who: "Moon", did: "Sang a lullaby")
            ]
        ),
        Exercise(
            id: "comprehension.ordering",
            levelId: "listening.comprehension",
            type: .ordering,
            title: "Ordering",
            summary: "Put the story in order",                      // TODO(copy)
            illustration: "ex_ordering",
            items: []
        ),
        Exercise(
            id: "comprehension.matching",
            levelId: "listening.comprehension",
            type: .matching,
            title: "Matching",
            summary: "Match what you hear",                         // TODO(copy)
            illustration: "ex_matching",
            items: []
        )
    ]
}
