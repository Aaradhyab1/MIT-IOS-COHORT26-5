import Foundation

/// Every state of the Sentences practice screen. The ViewModel exposes exactly one of
/// these, and the View draws the matching Figma frame
/// (Precoding_FINAL › 13 · Speech — Paragraphs).
enum SentencesPracticePhase: Equatable {
    /// "Paragraph 1 / idle": nothing read yet, the mic is waiting.
    case idle
    /// "Paragraph 1 / listening": "Reading aloud…", words light up as they are read.
    case reading
    /// "Paragraph 1 / paused": "Tap to continue reading".
    case paused

    // Recovery
    /// Listening ended, but no words were recognised at all.
    case noSpeech
    /// Listening stopped by itself (a phone call, an error, the recogniser's time limit).
    case interrupted
    /// The microphone or speech recogniser did not start, and why.
    case micFailed(ReadAloudFailure)
    /// The parent refused microphone or speech recognition access.
    case micDenied

    /// "Paragraphs / Completion": accuracy for the passage just read.
    case completed(SentencesResult)
}
