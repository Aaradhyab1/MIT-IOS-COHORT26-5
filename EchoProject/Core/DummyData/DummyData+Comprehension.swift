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
            pages: ["TODO(copy) story text"],
            events: ["TODO(copy) event 1", "TODO(copy) event 2", "TODO(copy) event 3"],
            pairs: placeholderPairs("pip")
        ),
        story(
            "brave-firetruck",
            title: "The brave little firetruck",
            pages: ["TODO(copy) story text"],
            events: ["TODO(copy) event 1", "TODO(copy) event 2", "TODO(copy) event 3"],
            pairs: placeholderPairs("firetruck")
        ),
        story(
            "olivia-starry-sky",
            title: "Olivia's starry sky",
            pages: ["TODO(copy) story text"],
            events: ["TODO(copy) event 1", "TODO(copy) event 2", "TODO(copy) event 3"],
            pairs: placeholderPairs("olivia")
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

    private static func placeholderPairs(_ story: String) -> [MatchPair] {
        (1...3).map { MatchPair(id: "\(story)-\($0)", who: "TODO(copy) who \($0)", did: "TODO(copy) did \($0)") }
    }
}
