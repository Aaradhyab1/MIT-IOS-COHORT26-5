import Foundation

/// How a word chip is coloured while reading.
enum WordHighlight: Equatable {
    case none
    /// Said correctly: green.
    case read
    /// Passed without being said correctly: soft red. Saying it again turns it green.
    case incorrect
    /// The word to read now: blue.
    case current
}
