import Foundation
import Observation

/// "Great start!": reveals the recommended level step by step (1 → 2 → 3),
/// then shows Continue, which saves the level and opens Home.
/// Figma: "Assessment / Result reveal — step 1", "— step 2", "— final" and "Great start / Level 3".
@Observable
@MainActor
final class QuickCheckResultViewModel {
    /// Number of level steps on the progress row (a ✓ follows them).
    let levelCount: Int
    let recommendation: LevelRecommendation?

    /// How many steps are lit so far; counts up to the recommended level.
    private(set) var revealedStep = 1
    private(set) var isContinueVisible = false

    /// "How scoring works" sheet, opened from the ⓘ on the card.
    var isScoringInfoPresented = false
    /// "Has the skill · 2 points", "Getting there · 1 point", "Not yet · 0 points".
    let answerValueRows: [ScoringRow] = [
        ScoringRow(label: "Has the skill", value: "2 points"),
        ScoringRow(label: "Getting there", value: "1 point"),
        ScoringRow(label: "Not yet", value: "0 points")
    ]
    /// "Level 1 · Detection · Questions 1–2", one row per level.
    let placementRows: [ScoringRow]

    private let router: AppRouter
    private let profile: any ProfileRepository
    private let stepDelay: Duration

    init(
        router: AppRouter,
        content: any ContentRepository,
        profile: any ProfileRepository,
        stepDelay: Duration = .milliseconds(650)
    ) {
        self.router = router
        self.profile = profile
        self.stepDelay = stepDelay

        let levels = content.levels(for: .listening)
        levelCount = levels.count
        let recommended = profile.quickCheckResult()?.recommendedLevel
            ?? profile.currentProfile()?.recommendedLevel
            ?? 1
        recommendation = levels.first { $0.order == recommended }.map(LevelRecommendation.init)

        let questions = content.quickCheckQuestions()
        placementRows = levels.map { level in
            let numbers = questions.indices
                .filter { questions[$0].levelOrder == level.order }
                .map { $0 + 1 }
            return ScoringRow(
                label: "Level \(level.order) \u{00B7} \(level.title)",
                value: Self.questionRange(numbers)
            )
        }
    }

    /// [1, 2] → "Questions 1–2", [5] → "Question 5".
    private static func questionRange(_ numbers: [Int]) -> String {
        guard let first = numbers.first, let last = numbers.last else { return "" }
        return first == last ? "Question \(first)" : "Questions \(first)\u{2013}\(last)"
    }

    /// "Level 3 of 4", read by VoiceOver for the progress row.
    var progressDescription: String {
        "Level \(revealedStep) of \(levelCount)"
    }

    /// Lights the steps one at a time, then shows Continue.
    /// With Reduce Motion everything appears at once.
    func didAppear(reduceMotion: Bool) async {
        let target = recommendation?.number ?? 1
        guard revealedStep < target || !isContinueVisible else { return }

        if reduceMotion {
            revealedStep = target
            isContinueVisible = true
            return
        }

        do {
            while revealedStep < target {
                try await Task.sleep(for: stepDelay)
                revealedStep += 1
            }
            try await Task.sleep(for: stepDelay)
            isContinueVisible = true
        } catch {
            // The screen went away; nothing to do.
        }
    }

    func didTapScoringInfo() {
        isScoringInfoPresented = true
    }

    func didCloseScoringInfo() {
        isScoringInfoPresented = false
    }

    /// Saves the recommended level as the starting level and opens Home.
    func didTapContinue() {
        var child = profile.currentProfile() ?? ChildProfile()
        child.recommendedLevel = recommendation?.number ?? 1
        child.onboardingCompleted = true
        profile.save(child)
        router.finishOnboarding()
    }
}
