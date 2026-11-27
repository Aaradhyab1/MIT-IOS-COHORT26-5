import Foundation

/// One card in "Your speech skills" (Sounds, Words, Sentences).
struct SkillCard: Identifiable, Hashable {
    let id: String          // level id
    let title: String       // "Sounds"
    let meta: String        // "Skill 1 · 4 min"
    let imageName: String
}
