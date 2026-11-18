import Foundation

/// The recurring cast drawn in the "Echo Paper" illustration style.
/// Used to show who is speaking in exercises and conversations.
enum EchoCharacter: String, Codable, Hashable, CaseIterable {
    case echo   // elephant mascot
    case pip    // puppy
    case mia
    case leo    // wears a hearing aid
    case zoe    // wears glasses
}
