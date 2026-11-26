import Foundation

/// Hardcoded progress matching the Figma "Progress v2" screens.
extension DummyData {
    private static let weekLetters = ["M", "T", "W", "T", "F", "S", "S"]
    private static let weekNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private static let todayIndex = 5

    private static func week(_ values: [Double?]) -> [ProgressDayValue] {
        values.enumerated().map { index, value in
            ProgressDayValue(id: index, letter: weekLetters[index], name: weekNames[index],
                             value: value, isToday: index == todayIndex)
        }
    }

    static let progressListeningLevel = ProgressLevel(
        name: "Identification",
        detail: "They’re finding familiar sounds in stories",
        number: 3, total: 4, completion: 0.65
    )

    static let progressSpeakingLevel = ProgressLevel(
        name: "Words",
        detail: "Growing their vocabulary through play.",
        number: 2, total: 4, completion: 0.58
    )

    static let progressOverview = ProgressOverviewReport(
        week: ProgressWeekSummary(
            streakDays: 5,
            sessions: 6,
            days: weekLetters.indices.map { index in
                let state: ProgressWeekDay.State = index < todayIndex ? .practiced : (index == todayIndex ? .today : .upcoming)
                return ProgressWeekDay(id: index, letter: weekLetters[index], name: weekNames[index], state: state)
            }
        ),
        paths: [
            ProgressPathSummary(track: .listening, level: progressListeningLevel, stats: [
                ProgressPathStat(value: "84%", label: "Accuracy"),
                ProgressPathStat(value: "12", label: "Games played"),
                ProgressPathStat(value: "4", label: "New sounds")
            ]),
            ProgressPathSummary(track: .speaking, level: progressSpeakingLevel, stats: [
                ProgressPathStat(value: "8", label: "New words"),
                ProgressPathStat(value: "26", label: "Words so far"),
                ProgressPathStat(value: "3", label: "Phrases")
            ])
        ]
    )

    static let listeningProgress = ListeningProgressReport(
        subtitle: "Sound milestones",
        level: progressListeningLevel,
        weeklyAccuracy: 0.84,
        accuracyChange: 0.06,
        dailyAccuracy: week([0.78, 0.82, 0.80, 0.86, 0.90, 0.88, nil]),
        skills: [
            ProgressSkill(id: "picture-matching", name: "Picture Matching", symbol: "photo", accent: .blue, score: 0.88),
            ProgressSkill(id: "minimal-pairs", name: "Minimal Pairs", symbol: "square.on.square", accent: .purple, score: 0.58),
            ProgressSkill(id: "word-identification", name: "Word Identification", symbol: "text.bubble", accent: .orange, score: 0.56)
        ],
        path: [
            ProgressPathStep(number: 1, title: "Detection", detail: nil, state: .done(note: "Aug 14")),
            ProgressPathStep(number: 2, title: "Differentiation", detail: nil, state: .done(note: "Sep 20")),
            ProgressPathStep(number: 3, title: "Identification", detail: nil, state: .current(completion: 0.65, note: "65%")),
            ProgressPathStep(number: 4, title: "Comprehension", detail: "Understanding what sounds mean", state: .upcoming(note: "Locked"))
        ],
        footnote: "Every sound they notice builds confidence."
    )

    static let speakingProgress = SpeakingProgressReport(
        subtitle: "Building words and expressing ideas",
        level: progressSpeakingLevel,
        newWordsThisWeek: 8,
        dailyWords: week([1, 2, 1, 1, 2, 1, nil]),
        wordExamples: ["puppy", "rain", "big"],
        moments: [
            ProgressSpeechMoment(id: "phrase", glyph: "“", accent: .blue,
                                 title: "“I found the puppy!”", detail: "Yesterday · A new phrase spoken!"),
            ProgressSpeechMoment(id: "playtime", glyph: "♪", accent: .green,
                                 title: "Used a new word at playtime", detail: "Sunday · Speaking"),
            ProgressSpeechMoment(id: "exploring", glyph: "Aa", accent: .purple,
                                 title: "Words in exploration", detail: "“puppy”, “rain”, “big”")
        ],
        path: [
            ProgressPathStep(number: 1, title: "Sounds", detail: "Trying out playful new sounds", state: .done(note: "Done")),
            ProgressPathStep(number: 2, title: "Words", detail: "Growing their vocabulary", state: .current(completion: 0.58, note: "8 words")),
            ProgressPathStep(number: 3, title: "Sentences", detail: "Putting words together", state: .upcoming(note: "Up next")),
            ProgressPathStep(number: 4, title: "Conversation", detail: "Sharing ideas back and forth", state: .upcoming(note: "Later"))
        ],
        footnote: "Every new word helps them share a little more."
    )
}
