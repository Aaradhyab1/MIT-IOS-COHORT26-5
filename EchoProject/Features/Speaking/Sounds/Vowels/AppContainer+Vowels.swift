import Foundation

/// ViewModel factory for Speaking — Sounds — Vowel sounds.
extension AppContainer {
    func makeVowelPracticeViewModel(exerciseId: String) -> VowelPracticeViewModel {
        VowelPracticeViewModel(exerciseId: exerciseId, recording: recording, voice: voice,
                               progress: progress, router: router)
    }
}
