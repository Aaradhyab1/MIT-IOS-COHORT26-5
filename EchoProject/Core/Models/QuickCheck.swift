import Foundation

struct QuickCheckQuestion: Codable, Identifiable, Hashable {
    let id: String
    let text: String
    let levelOrder: Int     // which Listening level this question probes (1–4)
    var hint: String? = nil         // grey line under the question, e.g. "For example, …"
    var choices: [String]? = nil    // extra chips to tap, e.g. the six Ling sounds (question 6)
}

enum QuickCheckAnswer: String, Codable, Hashable, CaseIterable {
    case often
    case sometimes
    case never
}

struct QuickCheckResult: Codable, Hashable {
    var answers: [String: QuickCheckAnswer]     // questionId → answer
    var recommendedLevel: Int                   // hardcoded to 3 for the demo, as in PRECODING
}

