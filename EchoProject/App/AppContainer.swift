import Foundation
import Observation

/// The composition root: creates every service once and builds ViewModels with them.
///
/// Views never create services or reach into repositories. A screen gets its ViewModel
/// from a factory method in its own folder, for example
/// `Features/Listening/Detection/AppContainer+Detection.swift`:
///
///     func makeListenAndRespondViewModel(exerciseId: String) -> ListenAndRespondViewModel {
///         ListenAndRespondViewModel(exerciseId: exerciseId, content: content,
///                                   audio: audio, progress: progress, router: router)
///     }
///
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
    /// Speech-to-text for the Speaking exercises.
    let speech: any SpeechRecognitionService
    /// Reads words and lines out loud in Speaking.
    let voice: any SpeechSynthesisService
    /// Reads the Comprehension stories out loud.
    let narrator: any StoryNarrationService

    /// The concrete dummy recorder, exposed so a debug menu can switch between
    /// normal, mic-denied and no-voice scenarios. Nil when the real recorder is used.
    let dummyRecording: DummyRecordingService?

    init(
        router: AppRouter,
        content: any ContentRepository,
        profile: any ProfileRepository,
        progress: any ProgressRepository,
        audio: any AudioPlaybackService,
        recording: any RecordingService,
        speech: any SpeechRecognitionService,
        voice: any SpeechSynthesisService,
        narrator: any StoryNarrationService,
        dummyRecording: DummyRecordingService? = nil
    ) {
        self.router = router
        self.content = content
        self.profile = profile
        self.progress = progress
        self.audio = audio
        self.recording = recording
        self.speech = speech
        self.voice = voice
        self.narrator = narrator
        self.dummyRecording = dummyRecording
    }

    /// Everything backed by hardcoded data. Used by the app, previews and tests.
    ///
    /// `liveSpeech: true` swaps in the iPhone's microphone, speech recognition,
    /// sound playback and voice. The data stays hardcoded either way.
    /// Previews and tests leave it off, so they never touch the microphone.
    static func dummy(startPastOnboarding: Bool = false, liveSpeech: Bool = false) -> AppContainer {
        let content = InMemoryContentRepository()
        let router = AppRouter(isOnboardingComplete: startPastOnboarding)
        let profile = InMemoryProfileRepository(profile: startPastOnboarding ? DummyData.sampleProfile : nil)
        let progress = InMemoryProgressRepository(content: content)

        if liveSpeech {
            return AppContainer(
                router: router,
                content: content,
                profile: profile,
                progress: progress,
                audio: BundleAudioPlaybackService(),
                recording: LiveRecordingService(),
                speech: LiveSpeechRecognitionService(),
                voice: SystemSpeechSynthesisService(),
                narrator: SpeechStoryNarrationService()
            )
        }

        let recording = DummyRecordingService()
        return AppContainer(
            router: router,
            content: content,
            profile: profile,
            progress: progress,
            audio: DummyAudioPlaybackService(),
            recording: recording,
            speech: DummySpeechRecognitionService(),
            voice: DummySpeechSynthesisService(),
            narrator: MockStoryNarrationService(),
            dummyRecording: recording
        )
    }

    // MARK: - Navigation support

    /// Which template plays an exercise. Lets RouteDestinationView pick a screen
    /// without reading a repository itself.
    func exerciseType(for exerciseId: String) -> ExerciseType? {
        content.exercise(id: exerciseId)?.type
    }

    /// The level an exercise belongs to. Sounds and Words share the same exercise
    /// type, so RouteDestinationView uses the level to tell them apart.
    func levelId(for exerciseId: String) -> String? {
        content.exercise(id: exerciseId)?.levelId
    }
}
