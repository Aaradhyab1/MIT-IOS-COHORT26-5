import Foundation
import Observation

/// The composition root: creates every service once and builds ViewModels with them.
///
/// Views never create services or reach into repositories. A screen gets its
/// ViewModel from a factory method, for example:
///
///     func makeDetectionViewModel(exerciseId: String) -> DetectionViewModel {
///         DetectionViewModel(exerciseId: exerciseId, content: content,
///                            audio: audio, progress: progress, router: router)
///     }
///
/// Factories live in one extension file per feature (`Features/<Feature>/AppContainer+<Feature>.swift`),
/// so teammates add screens without editing the same file.
/// Swapping dummy data for real storage later means changing only `dummy()` below.
@Observable
@MainActor
final class AppContainer {
    let router: AppRouter
    let content: any ContentRepository
    let profile: any ProfileRepository
    let progress: any ProgressRepository
    let audio: any AudioPlaybackService
    let recording: any RecordingService

    /// The concrete dummy recorder, exposed so a debug menu can switch between
    /// normal, mic-denied and no-voice scenarios. Nil once a real recorder is used.
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

    // MARK: - Navigation support

    /// Which template plays an exercise. Lets RouteDestinationView pick a screen
    /// without reading a repository itself.
    func exerciseType(for exerciseId: String) -> ExerciseType? {
        content.exercise(id: exerciseId)?.type
    }
}
