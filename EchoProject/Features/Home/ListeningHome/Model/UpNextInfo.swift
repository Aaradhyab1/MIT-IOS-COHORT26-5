import Foundation

/// The locked "Up next · Level 4" card at the bottom of Listening home.
struct UpNextInfo: Hashable {
    let eyebrow: String     // "Up next · Level 4"
    let title: String       // "Understand sounds"
    let detail: String      // "Play 4 more games to unlock."
    let imageName: String
}
