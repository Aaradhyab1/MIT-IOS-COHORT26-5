import Foundation

/// How many rounds an exercise really has and roughly how long it takes, worked out from
/// its content instead of fixed numbers. Shown as the "3 min" and "5 sounds" pills.
///
/// Durations are estimates for a young child with a grown-up beside them: time to listen,
/// answer or speak, and see feedback, per round. Rounded up to whole minutes, at least 1.
struct ExercisePlan: Equatable {
    let rounds: Int
    /// "sounds", "words", "phrases" …; singular when there is one round.
    let roundWord: String
    let minutes: Int

    /// "5 sounds", "1 paragraph".
    var roundsText: String { "\(rounds) \(roundWord)" }
    /// "3 min".
    var minutesText: String { "\(minutes) min" }

    /// - Parameter rounds: the number of rounds when the game doesn't play every item,
    ///   e.g. Words picks 5 of its 12 words, Vowel sounds plays its 3 sound friends.
    init(exercise: Exercise, rounds override: Int? = nil) {
        let items = exercise.items
        let questions = items.filter {
            $0.id.hasSuffix(StoryItemSuffix.ordering) || $0.id.hasSuffix(StoryItemSuffix.matching)
        }
        let storyPages = items.filter { item in
            !item.id.hasSuffix(StoryItemSuffix.ordering)
                && !item.id.hasSuffix(StoryItemSuffix.matching)
                && !item.id.hasSuffix(StoryItemSuffix.matchingAnswers)
        }

        let rounds: Int
        let word: String
        let seconds: Double
        switch exercise.type {
        case .listenAndRespond:
            rounds = override ?? items.count
            word = "sounds"
            seconds = Double(rounds) * 12          // play, then "I heard it" / "I didn't"
        case .oddOneOut:
            rounds = override ?? items.count
            word = "rounds"
            seconds = Double(rounds) * 20          // three friends' sounds, then a choice
        case .pictureChoice:
            rounds = override ?? items.count
            word = "sounds"
            seconds = Double(rounds) * 15          // play, look at 4 pictures, tap
        case .storyPlayer:
            rounds = override ?? questions.count
            word = "questions"
            let narration = storyPages.reduce(0.0) { $0 + Self.readingSeconds($1.text) + 4 }
            seconds = narration + Double(rounds) * 40
        case .ordering, .matching:
            rounds = override ?? items.count
            word = "rounds"
            seconds = Double(rounds) * 45
        case .listenAndRecord:
            rounds = override ?? items.count
            let isWords = exercise.levelId == "speaking.words"
            word = isWords ? "words" : "sounds"
            // A word: listen, record, hear it checked. A sound friend: meet it, say it 3 times.
            seconds = Double(rounds) * (isWords ? 20 : 40)
        case .readAlong:
            rounds = override ?? items.count
            word = Self.readingWord(for: exercise.id)
            // Read aloud at a child's pace, plus listening first and the result screen.
            seconds = items.prefix(rounds).reduce(0.0) { $0 + Self.readingSeconds($1.text) * 1.5 + 12 }
        case .conversation:
            rounds = override ?? items.count
            word = "questions"
            seconds = 20 + Double(rounds) * 25     // intro, then hear, choose, answer
        }

        self.rounds = rounds
        self.roundWord = rounds == 1 ? String(word.dropLast()) : word
        self.minutes = max(1, Int((seconds / 60).rounded(.up)))
    }

    /// About 1.2 words a second for a story read slowly to a child.
    private static func readingSeconds(_ text: String?) -> Double {
        let words = text?.split(whereSeparator: \.isWhitespace).count ?? 0
        return Double(words) / 1.2
    }

    private static func readingWord(for exerciseId: String) -> String {
        if exerciseId.hasSuffix("phrases") { return "phrases" }
        if exerciseId.hasSuffix("paragraphs") { return "paragraphs" }
        return "sentences"
    }
}
