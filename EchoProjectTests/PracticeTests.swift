import Foundation
import Testing
@testable import EchoProject

@MainActor
struct BeforeYouStartViewModelTests {
    private func makeViewModel(exerciseId: String, router: AppRouter = AppRouter(isOnboardingComplete: true)) -> BeforeYouStartViewModel {
        BeforeYouStartViewModel(
            exerciseId: exerciseId,
            content: InMemoryContentRepository(),
            audio: DummyAudioPlaybackService(simulatedDuration: .zero),
            router: router
        )
    }

    @Test func showsTheLevelTitleAndPillsForAListeningExercise() {
        let vm = makeViewModel(exerciseId: "identification.animals")

        #expect(vm.eyebrow == "LEVEL 3 · IDENTIFICATION")
        #expect(vm.title == "Animals")
        #expect(vm.metaPills == ["5 min", "10 sounds", "Headphones on"])
        #expect(vm.steps.count == 3)
        #expect(vm.canPlayExample)
    }

    @Test func speakingExercisesDoNotAskForHeadphones() throws {
        let content = InMemoryContentRepository()
        let firstSpeakingId = try #require(content.levels(for: .speaking).first?.exerciseIds.first)

        let vm = makeViewModel(exerciseId: firstSpeakingId)

        #expect(!vm.metaPills.contains("Headphones on"))
    }

    @Test func startOpensTheExercise() {
        let router = AppRouter(isOnboardingComplete: true)
        let vm = makeViewModel(exerciseId: "identification.animals", router: router)

        vm.start()

        #expect(router.listeningPath.count == 1)
    }

    @Test func theExampleStopsPlayingWhenTheClipEnds() async {
        let vm = makeViewModel(exerciseId: "identification.animals")

        await vm.playExample()

        #expect(!vm.isPlayingExample)
    }

    @Test func anUnknownExerciseShowsNotFound() {
        let vm = makeViewModel(exerciseId: "no.such.exercise")

        #expect(vm.title == "Exercise not found")
        #expect(!vm.canPlayExample)
    }
}

@MainActor
struct LeavePracticeTests {
    /// Listening tab with Before you start and the exercise pushed, overlay open.
    private func makeRouterInsideAnExercise() -> AppRouter {
        let router = AppRouter(isOnboardingComplete: true)
        router.go(.levelLibrary(levelId: "listening.identification"))
        router.go(.beforeYouStart(exerciseId: "identification.animals"))
        router.go(.exercise(exerciseId: "identification.animals"))
        router.presentLeavePractice()
        return router
    }

    @Test func keepPracticingClosesTheOverlayAndStaysOnTheExercise() {
        let router = makeRouterInsideAnExercise()
        let vm = LeavePracticeViewModel(audio: DummyAudioPlaybackService(), router: router)

        vm.keepPractising()

        #expect(router.overlay == nil)
        #expect(router.listeningPath.count == 3)
    }

    @Test func leaveGoesBackToWhereTheExerciseWasStarted() {
        let router = makeRouterInsideAnExercise()
        let vm = LeavePracticeViewModel(audio: DummyAudioPlaybackService(), router: router)

        vm.leave()

        #expect(router.overlay == nil)
        #expect(router.listeningPath.count == 1) // back on the level library
    }

    @Test func leaveNeverPopsPastTheRoot() {
        let router = AppRouter(isOnboardingComplete: true)
        router.go(.exercise(exerciseId: "identification.animals"))

        router.leavePractice()

        #expect(router.listeningPath.isEmpty)
    }
}
