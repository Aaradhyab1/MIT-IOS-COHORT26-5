import Foundation

/// Every state of the Words practice screen, in order. The ViewModel exposes exactly one
/// of these, and the View draws the matching Figma frame
/// (PRECODING › 12 · Speech — Words).
enum WordsPracticePhase: Equatable {
    /// Downloading the speech model the first time.
    case preparing

    // Listening
    case listen         // "Tap play to hear the word."
    case playing        // "Listening…"
    case listened       // "Press Record when you are ready."

    // Speaking
    case readyToRecord  // "Tap the mic, then say the word."
    case recording      // "Speak now."
    case checking       // speech recognition running

    /// Correct, close ("Almost there!") or incorrect.
    case result(WordVerdict)

    // Pronunciation help
    case help           // sound chips shown
    case guidedHelp     // each sound being said in turn

    // Recovery
    case noVoice        // "I didn't hear that." (recording was silent)
    case notUnderstood  // something was recorded, but no word was recognised
    case recordingFailed // the microphone did not start
    case micDenied      // "Allow microphone access to practise."
    case unavailable    // this iPhone cannot transcribe English

    case finished(Outcome)
}
