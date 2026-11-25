import Foundation

/// The two learning paths shown on the Progress tab. Also used as the navigation value
/// that opens each path's detail screen.
enum ProgressTrack: String, CaseIterable, Identifiable, Hashable {
    case listening
    case speaking

    var id: Self { self }

    var title: String {
        switch self {
        case .listening: "Listening"
        case .speaking: "Speaking"
        }
    }

    var symbol: String {
        switch self {
        case .listening: "ear"
        case .speaking: "mic.fill"
        }
    }
}
