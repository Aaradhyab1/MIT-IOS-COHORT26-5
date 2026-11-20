import Foundation

extension DummyData {

    // MARK: - Onboarding

    /// The 8 Quick Check questions (answered Often / Sometimes / Never), two per level.
    /// Copy from Figma: Precoding_FINAL › 02 · Onboarding › onboarding-listening-questionnaire.
    static let quickCheckQuestions: [QuickCheckQuestion] = [
        QuickCheckQuestion(
            id: "qc-1",
            text: "Does your child react to loud environmental sounds?",
            levelOrder: 1,
            hint: "For example, turns their head when a dog barks or a door slams."
        ),
        QuickCheckQuestion(
            id: "qc-2",
            text: "Can your child detect the six Ling sounds?",
            levelOrder: 1,
            hint: "Said at a normal speaking volume: m, ah, oo, ee, sh, s"
        ),
        QuickCheckQuestion(
            id: "qc-3",
            text: "Can your child hear the difference between two distinct sounds?",
            levelOrder: 2,
            hint: "Without seeing your face. For example, a phone ring vs. a dog bark."
        ),
        QuickCheckQuestion(
            id: "qc-4",
            text: "Can your child notice the difference between similar-sounding words?",
            levelOrder: 2,
            hint: "For example, pat, bat and mat."
        ),
        QuickCheckQuestion(
            id: "qc-5",
            text: "Can your child identify the item linked to a sound?",
            levelOrder: 3,
            hint: "For example, hears \u{201C}choo-choo\u{201D} and points to the train."
        ),
        QuickCheckQuestion(
            id: "qc-6",
            text: "Can your child identify the picture for each Ling sound?",
            levelOrder: 3,
            choices: ["M", "AH", "OO", "E", "SH", "S"]
        ),
        QuickCheckQuestion(
            id: "qc-7",
            text: "Can your child understand and follow 1-step spoken directions?",
            levelOrder: 4,
            hint: "Without pointing or gestures. For example, \u{201C}Get your shoes.\u{201D}"
        ),
        QuickCheckQuestion(
            id: "qc-8",
            text: "Can your child answer basic \u{201C}WH\u{201D} questions?",
            levelOrder: 4,
            hint: "Just by listening. For example, \u{201C}Where is the dog?\u{201D}"
        )
    ]

    /// A child who has finished onboarding, for screens that start past it
    /// (Home, Progress, previews).
    static let sampleProfile = ChildProfile(
        name: nil,
        hearingDevice: .cochlearImplant,
        recommendedLevel: 3,                        // "Great start! Level 3: Sound Identification"
        onboardingCompleted: true
    )

    // MARK: - Progress

    /// Practice on the last three days (a 3-day streak) plus one older session,
    /// so the Progress tab looks populated. Dates are relative to `now`.
    static func sessionHistory(now: Date = Date()) -> [SessionRecord] {
        func daysAgo(_ days: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -days, to: now) ?? now
        }
        return [
            SessionRecord(id: UUID(), exerciseId: "detection.hide-and-seek.animal", startedAt: daysAgo(6), correctCount: 2, totalCount: 2, outcome: .greatJob),
            SessionRecord(id: UUID(), exerciseId: "detection.hide-and-seek.doorbell", startedAt: daysAgo(3), correctCount: 1, totalCount: 2, outcome: .almostThere),
            SessionRecord(id: UUID(), exerciseId: "differentiation.odd-sound-out", startedAt: daysAgo(2), correctCount: 1, totalCount: 1, outcome: .greatJob),
            SessionRecord(id: UUID(), exerciseId: "words.three-letter", startedAt: daysAgo(1), correctCount: 1, totalCount: 1, outcome: .greatJob)
        ]
    }

    /// Starting values for the "3/10" counters on exercise cards.
    static let exerciseProgress: [ExerciseProgress] = [
        ExerciseProgress(exerciseId: "detection.hide-and-seek.animal", completedCount: 10, targetCount: 10, bestOutcome: .greatJob),
        ExerciseProgress(exerciseId: "detection.hide-and-seek.doorbell", completedCount: 3, targetCount: 10, bestOutcome: .almostThere),
        ExerciseProgress(exerciseId: "differentiation.odd-sound-out", completedCount: 1, targetCount: 10, bestOutcome: .greatJob),
        ExerciseProgress(exerciseId: "words.three-letter", completedCount: 2, targetCount: 10, bestOutcome: .greatJob)
    ]
}
