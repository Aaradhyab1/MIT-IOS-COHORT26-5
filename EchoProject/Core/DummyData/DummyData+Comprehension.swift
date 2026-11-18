import Foundation

extension DummyData {

    // MARK: - Comprehension exercises (Listening level 4)

    private static func story(_ id: String, title: String, pages: [String]) -> Exercise {
        Exercise(
            id: "comprehension.story.\(id)",
            levelId: "listening.comprehension",
            type: .storyPlayer,
            title: title,
            summary: "Listen to the story, then answer",            // TODO(copy)
            collection: "Stories",
            illustration: "ex_story-\(id)",
            items: pages.enumerated().map { index, page in
                ExerciseItem(
                    id: "\(id)-page-\(index + 1)",
                    audio: "snd_story-\(id)-\(index + 1)",
                    image: "img_story-\(id)-\(index + 1)",
                    text: page
                )
            }
        )
    }

    /// Level 4 exercises. Kept in their own file so the Comprehension owner edits
    /// only this file; the level itself is defined in DummyData+Listening.swift.
    static let comprehension: [Exercise] = [
        story("cat-and-bird", title: "The cat and the bird", pages: ["TODO(copy) page 1", "TODO(copy) page 2"]),
        story("pip-lost-marble", title: "Pip and the lost marble", pages: ["TODO(copy) page 1", "TODO(copy) page 2"]),
        story("brave-firetruck", title: "The brave little firetruck", pages: ["TODO(copy) page 1", "TODO(copy) page 2"]),
        story("olivia-starry-sky", title: "Olivia's starry sky", pages: ["TODO(copy) page 1", "TODO(copy) page 2"]),
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
