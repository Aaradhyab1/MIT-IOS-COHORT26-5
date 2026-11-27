import Foundation

/// ViewModel factories for Speaking — Conversation.
///
/// Every screen folder has its own factory file, so a teammate adding or changing a
/// screen only edits files inside their own folder.
extension AppContainer {
    func makeConversationViewModel(exerciseId: String) -> ConversationViewModel {
        ConversationViewModel(exerciseId: exerciseId, content: content, recording: recording,
                              speech: speech, voice: voice, progress: progress, router: router)
    }
}
