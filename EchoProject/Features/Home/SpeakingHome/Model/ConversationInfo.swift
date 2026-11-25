import Foundation

/// The "Conversation time" card on Speaking home.
struct ConversationInfo: Hashable {
    let exerciseId: String
    let title: String       // "Conversation"
    let detail: String      // "Put it all together and talk about your day."
    let imageName: String
}
