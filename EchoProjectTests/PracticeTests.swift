import Foundation
import SwiftUI
import Testing
@testable import EchoProject

@MainActor
struct BeforeYouStartViewModelTests {
    private let content = InMemoryContentRepository()

    private func makeViewModel(exerciseId: String, router: AppRouter? = nil) -> BeforeYouStartViewModel {
        BeforeYouStartViewModel(
            exerciseId: exerciseId,
            content: content,
            router: router ?? AppRouter(isOnboardingComplete: true)
        )
    }

    @Test func showsTheLevelTitleAndPlanForAListeningExercise() throws {
        let vm = makeViewModel(exerciseId: "identification.animals")
        let rounds = try #require(content.exercise(id: "identification.animals")).items.count

        #expect(vm.eyebrow == "LEVEL 3 · IDENTIFICATION")
        #expect(vm.title == "Animals")
        #expect(vm.metaPills.count == 2)
        #expect(vm.metaPills[1] == (rounds == 1 ? "1 sound" : "\(rounds) sounds"))
        #expect(vm.steps.count == 3)
    }

    @Test func noScreenAsksForHeadphones() {
        for level in content.levels(for: .listening) + content.levels(for: .speaking) {
            for id in level.exerciseIds {
                #expect(!makeViewModel(exerciseId: id).metaPills.contains("Headphones on"), "\(id)")
            }
        }
    }

    @Test func onlyVowelSoundsTalksAboutStars() {
        for level in content.levels(for: .listening) + content.levels(for: .speaking) {
            for id in level.exerciseIds {
                let words = makeViewModel(exerciseId: id).steps
                    .flatMap { ($0.title + " " + $0.detail).lowercased().split(whereSeparator: { !$0.isLetter }) }
                let mentionsStars = words.contains("star") || words.contains("stars")
                #expect(mentionsStars == (id == "sounds.vowel"), "\(id)")
            }
        }
    }

    @Test func roundsMatchWhatTheGamePlays() {
        #expect(makeViewModel(exerciseId: "sounds.vowel").metaPills[1] == "3 sounds")
        #expect(makeViewModel(exerciseId: "words.one-syllable").metaPills[1] == "5 words")
        #expect(makeViewModel(exerciseId: "sentences.simple-phrases").metaPills[1] == "5 phrases")
        #expect(makeViewModel(exerciseId: "sentences.paragraphs").metaPills[1] == "1 paragraph")
        #expect(makeViewModel(exerciseId: "comprehension.story.cat-and-bird").metaPills[1] == "2 questions")
    }

    @Test func durationsAreAtLeastAMinuteAndNotTheOldDefault() throws {
        let vm = makeViewModel(exerciseId: "sentences.short-sentences")
        let minutes = try #require(Int(vm.metaPills[0].split(separator: " ")[0]))
        #expect(minutes >= 1)
        #expect(minutes <= 3)
    }

    @Test func startOpensTheExercise() {
        let router = AppRouter(isOnboardingComplete: true)
        let vm = makeViewModel(exerciseId: "identification.animals", router: router)

        vm.start()

        #expect(router.listeningPath.count == 1)
    }

    @Test func anUnknownExerciseShowsNotFound() {
        let vm = makeViewModel(exerciseId: "no.such.exercise")

        #expect(vm.title == "Exercise not found")
        #expect(vm.metaPills.isEmpty)
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
