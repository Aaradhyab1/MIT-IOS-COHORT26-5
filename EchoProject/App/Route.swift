import Foundation

/// Every screen you can push onto a navigation stack.
/// Add a case here, and its destination in RouteDestinationView, for each new screen.
/// Shared by every feature: keep changes small to avoid merge conflicts.
enum Route: Hashable {
    // Onboarding
    case childProfile
    case choosePath             // Quick Check or pick a level yourself
    case chooseLevel            // custom level picker
    case quickCheck
    case quickCheckResult

    // Listening and Speaking
    case levelLibrary(levelId: String)
    case beforeYouStart(exerciseId: String)
    case exercise(exerciseId: String)
    case completion(exerciseId: String, outcome: Outcome)

    // Progress
    case listeningProgress
    case speakingProgress
}
