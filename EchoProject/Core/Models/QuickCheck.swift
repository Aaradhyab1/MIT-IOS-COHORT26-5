import Foundation

struct QuickCheckQuestion: Codable, Identifiable, Hashable {
    let id: String
    let text: String
    let levelOrder: Int     // which Listening level this question probes (1–4)
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
