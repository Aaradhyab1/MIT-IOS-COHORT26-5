import Foundation

/// Every state of the Vowel sounds practice (Figma: speech_temp › 14 · Speech — Sounds flow v2).
enum VowelPracticePhase: Equatable {
    /// "How it works".
    case intro
    /// "Meet Plane", play button.
    case meet
    /// Echo is saying the sound.
    case playing
    /// Mic ready; the friend waits at its current stop.
    case ready
    /// Recording one try.
    case listening
    /// The last try didn't count. The next stop shows a gentle "Try this one again".
    case tryAgain
    /// Three good tries: the friend reached its goal.
    case reachedGoal
    /// Microphone permission was refused.
    case micDenied
    /// "You met 3 sound friends!"
    case finished
}
