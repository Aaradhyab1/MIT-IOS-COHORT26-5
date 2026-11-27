import Foundation
import SwiftUI
import Testing
@testable import EchoProject

@MainActor
struct ProgressTests {

    // MARK: - Overview

    @Test func overviewStartsLoadingThenShowsTheWeekAndBothPaths() async throws {
        let vm = ProgressOverviewViewModel(service: MockProgressReportService(), router: AppRouter(isOnboardingComplete: true))
        #expect(vm.state == .loading)

        await vm.load()

        let report = try #require(vm.state.value)
        #expect(report.paths.map(\.track) == [.listening, .speaking])
        #expect(vm.streakText == "5-day streak")
        #expect(vm.sessionsText == "6 practice sessions")
    }

    @Test func overviewDescribesEachPath() async throws {
        let vm = ProgressOverviewViewModel(service: MockProgressReportService(), router: AppRouter(isOnboardingComplete: true))
        await vm.load()
        let listening = try #require(vm.state.value?.paths.first)

        #expect(vm.levelLine(for: listening) == "Identification · Level 3 of 4")
        #expect(vm.completedLine(for: listening) == "2 of 4 levels complete")
    }

    @Test func oneSessionIsSingular() async {
        let service = MockProgressReportService()
        let week = service.overviewReport.week
        service.overviewReport = ProgressOverviewReport(
            week: ProgressWeekSummary(streakDays: 1, sessions: 1, days: week.days),
            paths: service.overviewReport.paths
        )
        let vm = ProgressOverviewViewModel(service: service, router: AppRouter(isOnboardingComplete: true))

        await vm.load()

        #expect(vm.sessionsText == "1 practice session")
    }

    @Test func todayIsTheOnlyDayMarkedToday() async throws {
        let vm = ProgressOverviewViewModel(service: MockProgressReportService(), router: AppRouter(isOnboardingComplete: true))
        await vm.load()
        let days = try #require(vm.state.value?.week.days)

        #expect(days.count == 7)
        #expect(days.filter { $0.state == .today }.count == 1)
        #expect(days.filter { $0.state == .practiced }.count == 5)
    }

    @Test func loadingTwiceDoesNotFetchAgain() async {
        let service = MockProgressReportService()
        let vm = ProgressOverviewViewModel(service: service, router: AppRouter(isOnboardingComplete: true))

        await vm.load()
        await vm.load()

        #expect(service.loadCount == 1)
    }

    @Test func aFailedLoadShowsAMessageAndRetryRecovers() async {
        let service = MockProgressReportService(failsToLoad: true)
        let vm = ProgressOverviewViewModel(service: service, router: AppRouter(isOnboardingComplete: true))

        await vm.load()
        guard case .failed = vm.state else {
            Issue.record("Expected the error state")
            return
        }

        service.failsToLoad = false
        await vm.didTapRetry()
        #expect(vm.state.value != nil)
    }

    @Test func tappingAPathCardOpensItsDetailScreen() {
        let router = AppRouter(isOnboardingComplete: true)
        router.selectedTab = .progress
        let vm = ProgressOverviewViewModel(service: MockProgressReportService(), router: router)

        vm.didTapPath(.listening)
        #expect(router.progressPath.count == 1)

        vm.didTapPath(.speaking)
        #expect(router.progressPath.count == 2)
    }

    // MARK: - Listening

    @Test func listeningShowsTheCurrentLevelAndChartCallout() async throws {
        let vm = ListeningProgressViewModel(service: MockProgressReportService(), router: AppRouter(isOnboardingComplete: true))
        await vm.load()
        let report = try #require(vm.state.value)

        #expect(report.level.name == "Identification")
        #expect(vm.chipText == "Level 3 of 4")
        #expect(vm.latestDayId == 5)
        #expect(vm.accuracyIsUp)
        #expect(report.dailyAccuracy.last?.value == nil)
    }

    @Test func weeklyAccuracyIsTheAverageOfScoredDays() async throws {
        let vm = ListeningProgressViewModel(service: MockProgressReportService(), router: AppRouter(isOnboardingComplete: true))
        await vm.load()
        let report = try #require(vm.state.value)
        let scores = report.dailyAccuracy.compactMap(\.value)

        let average = scores.reduce(0, +) / Double(scores.count)
        #expect(abs(average - report.weeklyAccuracy) < 0.005)
    }

    @Test func skillsAboveThreeQuartersAreGoingStrong() async throws {
        let vm = ListeningProgressViewModel(service: MockProgressReportService(), router: AppRouter(isOnboardingComplete: true))
        await vm.load()
        let skills = try #require(vm.state.value?.skills)

        #expect(skills.map(\.status) == [.goingStrong, .growing, .growing])
    }

    @Test func eachPathHasOneCurrentLevel() async throws {
        let listening = ListeningProgressViewModel(service: MockProgressReportService(), router: AppRouter(isOnboardingComplete: true))
        let speaking = SpeakingProgressViewModel(service: MockProgressReportService(), router: AppRouter(isOnboardingComplete: true))
        await listening.load()
        await speaking.load()

        for path in [try #require(listening.state.value?.path), try #require(speaking.state.value?.path)] {
            let current = path.filter {
                if case .current = $0.state { return true }
                return false
            }
            #expect(current.count == 1)
            #expect(path.map(\.number) == [1, 2, 3, 4])
        }
    }

    // MARK: - Speaking

    @Test func speakingWordsAddUpToTheWeeklyTotal() async throws {
        let vm = SpeakingProgressViewModel(service: MockProgressReportService(), router: AppRouter(isOnboardingComplete: true))
        await vm.load()
        let report = try #require(vm.state.value)

        let total = report.dailyWords.compactMap(\.value).reduce(0, +)
        #expect(Int(total) == report.newWordsThisWeek)
        #expect(vm.chipText == "Level 2 of 4")
        #expect(vm.bestDayId == 1)
    }

    @Test func speakingFailureShowsTheErrorState() async {
        let vm = SpeakingProgressViewModel(service: MockProgressReportService(failsToLoad: true), router: AppRouter(isOnboardingComplete: true))

        await vm.load()

        #expect(vm.state.value == nil)
        #expect(vm.state != .loading)
    }
}
