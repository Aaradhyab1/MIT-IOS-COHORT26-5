import SwiftUI

struct SkillsCard: View {
    let skills: [ProgressSkill]
    let tint: Color

    var body: some View {
        ProgressPlainCard {
            VStack(spacing: 18) {
                ForEach(skills) { skill in
                    SkillRow(skill: skill, tint: tint)
                }
            }
        }
    }
}
