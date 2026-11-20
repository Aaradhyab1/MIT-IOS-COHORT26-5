import Foundation
import Observation

/// The 8-question Quick Check. One question at a time; picking Often, Sometimes or
/// Never moves on to the next question by itself. After the last one the answers are
/// saved and the result screen opens.
@Observable
@MainActor
final class QuickCheckViewModel {
    /// The demo always recommends Level 3, as in the prototype ("Great start! Level 3").
    /// Real scoring from `answers` goes here later.
    static let demoRecommendedLevel = 3

    let questions: [QuickCheckQuestion]

    private(set) var currentIndex = 0
    private(set) var answers: [String: QuickCheckAnswer] = [:]
    /// Ling sounds ticked on question 6.
    private(set) var selectedChoices: Set<String> = []

    private let router: AppRouter
    private let profile: any ProfileRepository
    /// Short pause after an answer so the parent sees it selected before the next question.
    private let advanceDelay: Duration
    private var advanceTask: Task<Void, Never>?

    init(
        router: AppRouter,
        content: any ContentRepository,
        profile: any ProfileRepository,
        advanceDelay: Duration = .milliseconds(350)
    ) {
        self.router = router
        self.profile = profile
        self.advanceDelay = advanceDelay
        questions = content.quickCheckQuestions()
    }

    // MARK: - State for the View

    var currentQuestion: QuickCheckQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    /// "Question 3 of 8"
    var questionNumberText: String {
        "Question \(currentIndex + 1) of \(questions.count)"
    }

    /// The segmented control's selection. Setting it records the answer and moves on.
    var currentAnswer: QuickCheckAnswer? {
        get { currentQuestion.flatMap { answers[$0.id] } }
        set {
            if let newValue { didSelect(newValue) }
        }
    }

    func label(for answer: QuickCheckAnswer) -> String {
        switch answer {
        case .often: "Often"
        case .sometimes: "Sometimes"
        case .never: "Never"
        }
    }

    func isChoiceSelected(_ choice: String) -> Bool {
        selectedChoices.contains(choice)
    }

    // MARK: - Actions

    func didSelect(_ answer: QuickCheckAnswer) {
        guard let question = currentQuestion else { return }
        answers[question.id] = answer

        advanceTask?.cancel()
        let delay = advanceDelay
        advanceTask = Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            self?.goToNextQuestion()
        }
    }

    func didToggleChoice(_ choice: String) {
        if selectedChoices.contains(choice) {
            selectedChoices.remove(choice)
        } else {
            selectedChoices.insert(choice)
        }
    }

    /// Back goes to the previous question; on question 1 it leaves the Quick Check.
    func didTapBack() {
        advanceTask?.cancel()
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            router.back()
        }
    }

    /// Next question, or the result after the last one.
    func goToNextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            finish()
        }
    }

    // MARK: - Private

    private func finish() {
        profile.saveQuickCheck(QuickCheckResult(answers: answers, recommendedLevel: Self.demoRecommendedLevel))
        router.go(.quickCheckResult)
    }
}
