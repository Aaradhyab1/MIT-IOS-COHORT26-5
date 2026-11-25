import Foundation

/// Today's practice text for each Speaking skill. Skill 1 is from Figma
/// ("Speech Sounds"). TODO(copy): skills 2–3 follow the same voice; check with the designer.
enum SpeakingSkillCopy {
    static func heroTitle(forSkill number: Int) -> String {
        switch number {
        case 1: "Speech Sounds"
        case 2: "First Words"
        case 3: "Read Along"
        default: "Let's Talk"
        }
    }

    static func heroSummary(forSkill number: Int) -> String {
        switch number {
        case 1: "Listen to Echo, then say the sound out loud."
        case 2: "Listen to the word, then say it out loud."
        case 3: "Read along, then tap any word to hear it."
        default: "Put it all together and talk about your day."
        }
    }

    /// What the count pill counts: "4 sounds", "4 words".
    static func itemWord(forSkill number: Int) -> String {
        switch number {
        case 1: "sounds"
        case 2: "words"
        case 3: "sentences"
        default: "chats"
        }
    }
}
