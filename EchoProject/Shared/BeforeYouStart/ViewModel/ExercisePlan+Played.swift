import Foundation

extension ExercisePlan {
    /// The plan for the rounds the game actually plays. Some games don't play every item:
    /// Words picks a few of its words each time, and Vowel sounds plays its sound friends.
    static func played(_ exercise: Exercise) -> ExercisePlan {
        let rounds: Int?
        if exercise.id == "sounds.vowel" {
            rounds = SoundFriend.vowelFriends.count
        } else if exercise.levelId == "speaking.words" {
            rounds = min(exercise.items.count, WordsPracticeViewModel.wordsPerSession)
        } else {
            rounds = nil
        }
        return ExercisePlan(exercise: exercise, rounds: rounds)
    }
}
