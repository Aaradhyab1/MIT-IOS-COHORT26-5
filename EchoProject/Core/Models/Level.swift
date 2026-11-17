import Foundation

/// A level inside a track ("Stage" was renamed to "Level" across the app).
///
/// Listening: 1 Detection, 2 Differentiation, 3 Identification, 4 Comprehension.
/// Speaking:  1 Sounds, 2 Words, 3 Paragraphs, 4 Conversation.
struct Level: Codable, Identifiable, Hashable {
    let id: String              // "listening.detection"
    let track: Track
    let order: Int              // 1-based, drives the level journey path
    let title: String           // "Detection"
    let subtitle: String        // "Notice when a sound is there"
    let illustration: String    // asset name in Assets.xcassets
    let exerciseIds: [String]   // in display order
}
