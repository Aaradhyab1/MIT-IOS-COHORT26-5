import Foundation

/// How one stop on the sound path looks.
enum PathStop: Equatable {
    /// Not reached yet.
    case waiting
    /// Reached with a good try: yellow star.
    case reached
    /// The last try for this stop didn't count. Soft coral ring, never red.
    case tryAgain
}
