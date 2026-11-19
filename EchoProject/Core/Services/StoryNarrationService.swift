import Foundation

/// What the narrator reports back while it reads a story.
enum NarrationEvent: Equatable {
    case started
    case progress(Double)
    case paused
    case resumed
    case finished
    case failed(String)
}

/// Reading speeds offered to the child. Ages 5–8 follow a story best at roughly
/// 120–160 words per minute, a little slower than the adult default.
enum NarrationSpeed: String, CaseIterable, Identifiable {
    case slow
    case normal
    case fast

    var id: Self { self }

    var label: String {
        switch self {
        case .slow: "Slow"
        case .normal: "Normal"
        case .fast: "Fast"
        }
    }

    var symbol: String {
        switch self {
        case .slow: "tortoise.fill"
        case .normal: "figure.walk"
        case .fast: "hare.fill"
        }
    }

    /// `AVSpeechUtterance.rate`, where 0.5 is the system default.
    var rate: Float {
        switch self {
        case .slow: 0.36
        case .normal: 0.42
        case .fast: 0.48
        }
    }

    var wordsPerMinute: Double {
        switch self {
        case .slow: 120
        case .normal: 140
        case .fast: 160
        }
    }
}

/// Reads a story's text aloud. Events arrive on the main actor through `onEvent`.
@MainActor
protocol StoryNarrationService: AnyObject {
    var onEvent: ((NarrationEvent) -> Void)? { get set }
    /// Starts reading from the sentence at `fraction` (0...1) of the text.
    func speak(_ text: String, from fraction: Double, speed: NarrationSpeed)
    func pause()
    func resume()
    func stop()
}

extension StoryNarrationService {
    /// Length shown on the audio bar, in seconds, including the short pause after each sentence.
    func estimatedDuration(of text: String, speed: NarrationSpeed) -> TimeInterval {
        let words = text.split { $0.isWhitespace }.count
        let sentences = StoryText.sentences(in: text).count
        return Double(words) / speed.wordsPerMinute * 60 + Double(sentences) * StoryText.pauseAfterSentence
    }
}

/// One sentence of a story and where it starts in the full text (UTF-16 offset,
/// the unit `AVSpeechSynthesizer` reports progress in).
struct StorySentence: Equatable {
    let text: String
    let offset: Int
}

enum StoryText {
    /// Seconds of silence after each sentence, so young listeners can follow along.
    static let pauseAfterSentence: TimeInterval = 0.35

    static func sentences(in text: String) -> [StorySentence] {
        var result: [StorySentence] = []
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences) { sentence, range, _, _ in
            guard let sentence, !sentence.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            let offset = text.utf16.distance(from: text.utf16.startIndex, to: range.lowerBound)
            result.append(StorySentence(text: sentence, offset: offset))
        }
        return result
    }
}
