import Foundation

/// Story items: pages have no options; ids ending in these suffixes are the questions.
/// Ordering options are in the correct order; matching answers share ids with their characters.
enum StoryItemSuffix {
    static let ordering = ".ordering"
    static let matching = ".matching"
    static let matchingAnswers = ".matching-answers"
}
