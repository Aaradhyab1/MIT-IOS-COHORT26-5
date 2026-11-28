import Foundation

/// What the vowel check found in one try.
nonisolated struct VowelCheck: Hashable {
    /// True when the child held the expected vowel long enough.
    let isMatch: Bool
    /// The vowel family heard most, as IPA ("ɑ", "u", "i"), or nil if none was clear.
    let heard: String?
    /// Seconds of the try that sounded like the expected vowel.
    let matchingSeconds: TimeInterval
}

/// Listens to a finished recording and says whether it was the expected vowel.
@MainActor
protocol VowelCheckService: AnyObject {
    /// `ipa` is the friend's sound, e.g. "ɑː" for Plane. A length mark is ignored.
    func check(_ recording: RecordingResult, expecting ipa: String) async -> VowelCheck
}

/// Previews, tests and the dummy demo: every try with a voice counts.
@MainActor
final class DummyVowelCheckService: VowelCheckService {
    var answer = true

    func check(_ recording: RecordingResult, expecting ipa: String) async -> VowelCheck {
        VowelCheck(isMatch: answer, heard: answer ? VowelFormants.family(of: ipa) : nil,
                   matchingSeconds: answer ? recording.duration : 0)
    }
}
