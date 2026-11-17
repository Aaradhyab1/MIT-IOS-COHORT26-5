import Foundation

/// The two learning tracks, shown as the Listening and Speaking tabs.
enum Track: String, Codable, Hashable, CaseIterable {
    case listening
    case speaking
}

/// The recurring cast drawn in the "Echo Paper" style.
enum EchoCharacter: String, Codable, Hashable, CaseIterable {
    case echo   // elephant mascot
    case pip    // puppy
    case mia
    case leo    // wears a hearing aid
    case zoe    // wears glasses
}
