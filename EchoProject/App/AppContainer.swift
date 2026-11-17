import Foundation
import Observation

/// Builds every service once and hands them to ViewModels. Owner: Dev A.
///
/// Views never create services. A screen gets its ViewModel from a factory
/// method here, e.g.:
///
///     func makeDetectionViewModel(exerciseId: String) -> DetectionViewModel {
///         DetectionViewModel(exerciseId: exerciseId, content: content,
///                            audio: audio, progress: progress, router: router)
///     }
///
/// Each dev adds factories for their own screens in the MARK section below.
@Observable
@MainActor
final class AppContainer {
    let router: AppRouter
    let content: any ContentRepository
    let profile: any ProfileRepository
    let progress: any ProgressRepository
    let audio: any AudioPlaybackService
    let recording: any RecordingService

    /// The concrete dummy recorder, so the hidden debug menu can switch
    /// between normal / mic denied / no voice. Nil once a real recorder exists.
    let dummyRecording: DummyRecordingService?

    init(
        router: AppRouter,
        content: any ContentRepository,
        profile: any ProfileRepository,
        progress: any ProgressRepository,
        audio: any AudioPlaybackService,
        recording: any RecordingService,
        dummyRecording: DummyRecordingService? = nil
    ) {
        self.router = router
        self.content = content
        self.profile = profile
        self.progress = progress
        self.audio = audio
        self.recording = recording
        self.dummyRecording = dummyRecording
    }

    /// Everything backed by hardcoded data. Used by the app, previews and tests.
    static func dummy(startPastOnboarding: Bool = false) -> AppContainer {
        let content = InMemoryContentRepository()
        let recording = DummyRecordingService()
        return AppContainer(
            router: AppRouter(isOnboardingComplete: startPastOnboarding),
            content: content,
            profile: InMemoryProfileRepository(profile: startPastOnboarding ? DummyData.sampleProfile : nil),
            progress: InMemoryProgressRepository(content: content),
            audio: DummyAudioPlaybackService(),
            recording: recording,
            dummyRecording: recording
        )
    }

    // MARK: - ViewModel factories
    // Dev A: onboarding, home
    // Dev B: listening templates, level libraries
    // Dev C: speaking templates, speaking library
    // Dev D: progress, story player
}
