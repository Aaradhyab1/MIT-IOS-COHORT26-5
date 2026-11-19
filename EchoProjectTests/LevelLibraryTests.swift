import Foundation
import Testing
@testable import EchoProject

@MainActor
struct LevelLibraryTests {
    private func makeViewModel(
        levelId: String,
        router: AppRouter = AppRouter(isOnboardingComplete: true)
    ) -> LevelLibraryViewModel {
        let content = InMemoryContentRepository()
        let progress = InMemoryProgressRepository(content: content, sessions: [], progress: [])
        return LevelLibraryViewModel(levelId: levelId, content: content, progress: progress, router: router)
    }

    private func sections(_ vm: LevelLibraryViewModel) -> [LevelLibraryViewModel.Section] {
        if case .ready(_, let sections) = vm.state { return sections }
        return []
    }

    @Test func showsTheLevelTitleAndEveryExercise() {
        let vm = makeViewModel(levelId: "listening.differentiation")

        guard case .ready(let title, let sections) = vm.state else {
            Issue.record("Expected .ready, got \(vm.state)")
            return
        }
        #expect(title == "Differentiation")
        #expect(sections.flatMap(\.rows).count == 7)
    }

    @Test func groupsExercisesByCollection() {
        let first = sections(makeViewModel(levelId: "listening.differentiation")).first

        #expect(first?.title == "Which One Sounds Different")
        #expect(first?.rows.map(\.title) == ["Odd Sound Out", "Loud or Soft", "High or Low", "Fast or Slow"])
    }

    @Test func newExercisesStartAtZeroOfTen() {
        let row = sections(makeViewModel(levelId: "listening.identification")).first?.rows.first

        #expect(row?.countText == "0 / 10")
        #expect(row?.fraction == 0)
    }

    @Test func unknownLevelShowsAnError() {
        let vm = makeViewModel(levelId: "nope")

        #expect(vm.state == .error("This level could not be found."))
    }

    @Test func tappingACardGoesToBeforeYouStart() {
        let router = AppRouter(isOnboardingComplete: true)
        let vm = makeViewModel(levelId: "listening.detection", router: router)

        vm.didTap(sections(vm)[0].rows[0])

        #expect(router.listeningPath.count == 1)
    }
}
