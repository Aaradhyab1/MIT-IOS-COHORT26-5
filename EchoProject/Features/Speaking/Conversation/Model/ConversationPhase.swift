import Foundation

/// Every state of the Conversation screen. The ViewModel exposes exactly one, and the
/// View draws the matching Figma frame (kalp › 14 · Speech — Conversation).
enum ConversationPhase: Equatable {
    /// 01 — At the Ice Cream Shop: "Meet your shopkeeper", Start Conversation.
    case intro
    /// Downloading the speech model the first time.
    case preparing
    /// The shopkeeper is talking: a question, "you can only choose…", or
    /// "Chocolate, great choice!" before the next question.
    case shopkeeperTalking
    /// 02 — Tap to speak.
    case yourTurn
    /// 03 — Recording; the red button stops it.
    case recording
    /// Speech recognition running.
    case checking
    /// "Here you go! Your ice cream is ready." with the ice cream the child ordered.
    case finished
    case micDenied
    /// This iPhone cannot transcribe English.
    case unavailable
}
