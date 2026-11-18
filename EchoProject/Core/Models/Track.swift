import Foundation

/// The two learning tracks, shown as the Listening and Speaking tabs.
enum Track: String, Codable, Hashable, CaseIterable {
    case listening
    case speaking
}
