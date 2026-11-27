import Foundation

/// How a word chip is coloured while reading.
enum WordHighlight: Equatable {
    case none
    /// Already read: green.
    case read
    /// The word to read now: blue.
    case current
}
