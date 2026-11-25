import Foundation
import Observation

/// Speaking home: greeting, Today's practice for the current skill,
/// "Your speech skills" (Sounds, Words, Sentences) and "Conversation time".
@Observable
@MainActor
final class SpeakingHomeViewModel {
    private(set) var greeting = ""
    private(set) var todaysPractice: TodaysPractice?
    private(set) var skillCards: [SkillCard] = []
    private(set) var conversation: ConversationInfo?

    private let content: any ContentRepository
    private let progress: any ProgressRepository
    private let router: AppRouter
    private let now: () -> Date

    init(
        content: any ContentRepository,
        progress: any ProgressRepository,
        router: AppRouter,
        now: @escaping () -> Date = Date.init
    ) {
        self.content = content
        self.progress = progress
        self.router = router
        self.now = now
        refresh()
    }

    // MARK: - Building the screen

    func refresh() {
        greeting = Greeting.text(for: now())

        let levels = content.levels(for: .speaking)
        let practiceLevels = levels.filter { content.exercises(inLevel: $0.id).first?.type != .conversation }
        let conversationLevel = levels.first { content.exercises(inLevel: $0.id).first?.type == .conversation }

        // Current skill: the first one with an exercise still to finish.
        let current = practiceLevels.first { level in
            content.exercises(inLevel: level.id).contains { !progress.progress(for: $0.id).isComplete }
        } ?? practiceLevels.first

        if let current {
            let exercises = content.exercises(inLevel: current.id)
            let pick = exercises.first { isInProgress($0.id) }
                ?? exercises.first { !progress.progress(for: $0.id).isComplete }
                ?? exercises.first
            todaysPractice = pick.map { exercise in
                TodaysPractice(
                    exerciseId: exercise.id,
                    badgeNumber: current.order,
                    badgeText: "You're on Skill \(current.order)",
                    title: SpeakingSkillCopy.heroTitle(forSkill: current.order),
                    summary: SpeakingSkillCopy.heroSummary(forSkill: current.order),
                    minutesText: "\(exercise.durationMinutes) min",
                    countText: "\(exercises.count) \(SpeakingSkillCopy.itemWord(forSkill: current.order))"
                )
            }
        } else {
            todaysPractice = nil
        }

        skillCards = practiceLevels.map { level in
            let minutes = content.exercises(inLevel: level.id).first?.durationMinutes ?? 5
            return SkillCard(
                id: level.id,
                title: level.title,
                meta: "Skill \(level.order) \u{00B7} \(minutes) min",
                imageName: level.illustration
            )
        }

        if let conversationLevel, let exercise = content.exercises(inLevel: conversationLevel.id).first {
            conversation = ConversationInfo(
                exerciseId: exercise.id,
                title: conversationLevel.title,
                detail: "Put it all together and talk about your day.",
                imageName: conversationLevel.illustration
            )
        } else {
            conversation = nil
        }
    }

    // MARK: - Actions

    func didTapStart() {
        guard let todaysPractice else { return }
        router.go(.beforeYouStart(exerciseId: todaysPractice.exerciseId))
    }

    func didTapSkill(_ card: SkillCard) {
        router.go(.levelLibrary(levelId: card.id))
    }

    func didTapStartTalking() {
        guard let conversation else { return }
        router.go(.beforeYouStart(exerciseId: conversation.exerciseId))
    }

    /// TODO: open the parent Profile (Figma "15 · Profile & Settings") once it is built.
    func didTapProfile() {}

    // MARK: - Private

    private func isInProgress(_ exerciseId: String) -> Bool {
        let p = progress.progress(for: exerciseId)
        return p.completedCount > 0 && !p.isComplete
    }
}
