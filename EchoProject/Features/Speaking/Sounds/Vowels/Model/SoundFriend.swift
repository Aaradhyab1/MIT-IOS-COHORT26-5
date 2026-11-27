import Foundation

/// A "sound friend": the character a vowel is practised with, e.g. Plane says "aaa".
///
/// Pairing a sound with a picture is how therapists teach first sounds (the "Learning to
/// Listen" sounds). Later sessions can rotate friends or fade the picture so the child
/// doesn't tie a vowel to one object.
struct SoundFriend: Identifiable, Hashable {
    let id: String
    /// "Plane"
    let name: String
    /// How the sound is written on screen: "aaa".
    let vowel: String
    /// IPA the voice reads, so it says the sound, not a letter name.
    let ipa: String
    /// Where the friend travels to: "the cloud".
    let goalName: String
    /// Finished line on the Hooray screen.
    let goalLine: String

    // Artwork. Each name shows a dashed placeholder until the asset is added.
    /// Large picture on the Meet screen.
    let meetImage: String
    /// Small picture that moves along the path.
    let travelImage: String
    /// The destination at the end of the path.
    let goalImage: String
    /// Optional picture for the Hooray screen; the path is shown when nil.
    let celebrateImage: String?
}
