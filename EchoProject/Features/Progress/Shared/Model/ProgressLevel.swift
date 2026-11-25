import Foundation

/// Where the child is on a path: the level they are in and how far through it they are.
struct ProgressLevel: Hashable {
    let name: String
    let detail: String
    let number: Int
    let total: Int
    /// 0...1 through the current level.
    let completion: Double

    var completedLevels: Int { number - 1 }
}
