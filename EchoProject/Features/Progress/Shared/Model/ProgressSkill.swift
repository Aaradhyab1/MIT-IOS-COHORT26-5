import Foundation

/// A skill inside the current listening level, with how well it is going.
struct ProgressSkill: Identifiable, Hashable {
    enum Status: Hashable {
        case goingStrong
        case growing

        var title: String {
            switch self {
            case .goingStrong: "Going strong"
            case .growing: "Growing"
            }
        }
    }

    let id: String
    let name: String
    let symbol: String
    let accent: ProgressAccent
    /// 0...1
    let score: Double

    /// 75% and above counts as going strong.
    var status: Status { score >= 0.75 ? .goingStrong : .growing }
}
