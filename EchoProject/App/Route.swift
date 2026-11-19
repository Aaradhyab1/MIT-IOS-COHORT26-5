import Foundation

/// Every screen you can push onto a navigation stack.
/// Each case is drawn by RouteDestinationView. Add a case only when a new screen needs
/// one, and tell the team: this file is shared by every feature.
enum Route: Hashable {
    // Onboarding
    case childProfile
    case choosePath             // Quick Check, or a custom level from an overlay
    case quickCheck
    case quickCheckResult

    // Listening and Speaking (shared screens and the exercises themselves)
    case levelLibrary(levelId: String)
    case exerciseCollection(levelId: String, collection: String)   // e.g. "Story Hide & Seek"
    case beforeYouStart(exerciseId: String)
    case exercise(exerciseId: String)
    case completion(exerciseId: String, outcome: Outcome)

    // Progress
    case listeningProgress
    case speakingProgress
}
