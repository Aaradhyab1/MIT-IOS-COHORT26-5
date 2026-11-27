import Foundation

extension SoundFriend {
    /// The three friends in one Vowel sounds practice, in order.
    static let vowelFriends: [SoundFriend] = [
        SoundFriend(
            id: "plane", name: "Plane", vowel: "aaa", ipa: "ɑː",
            goalName: "the cloud", goalLine: "Plane flew all the way\nto the cloud!",
            meetImage: "img_vowel_plane", travelImage: "img_vowel_plane_travel",
            goalImage: "img_vowel_goal_cloud", celebrateImage: "img_vowel_plane_cloud"
        ),
        SoundFriend(
            id: "owl", name: "Owl", vowel: "ooo", ipa: "uː",
            goalName: "the moon", goalLine: "Owl flew all the way\nto the moon!",
            meetImage: "img_vowel_owl", travelImage: "img_vowel_owl_travel",
            goalImage: "img_vowel_goal_moon", celebrateImage: nil
        ),
        SoundFriend(
            id: "mouse", name: "Mouse", vowel: "eee", ipa: "iː",
            goalName: "the cheese", goalLine: "Mouse got to the cheese!",
            meetImage: "img_vowel_mouse", travelImage: "img_vowel_mouse_travel",
            goalImage: "img_vowel_goal_cheese", celebrateImage: nil
        ),
    ]
}
