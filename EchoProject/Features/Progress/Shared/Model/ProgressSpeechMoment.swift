import Foundation

/// An everyday speaking win, for example a new phrase.
struct ProgressSpeechMoment: Identifiable, Hashable {
    let id: String
    let glyph: String
    let accent: ProgressAccent
    let title: String
    let detail: String
}
