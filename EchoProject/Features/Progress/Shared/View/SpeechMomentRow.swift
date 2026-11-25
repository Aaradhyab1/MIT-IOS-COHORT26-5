import SwiftUI

struct SpeechMomentRow: View {
    let moment: ProgressSpeechMoment

    var body: some View {
        HStack(spacing: 12) {
            ProgressIconTile(content: .glyph(moment.glyph), accent: moment.accent, size: 40, cornerRadius: 12)
            VStack(alignment: .leading, spacing: 1) {
                Text(moment.title)
                    .font(.headline)
                    .foregroundStyle(ProgressPalette.textPrimary)
                Text(moment.detail)
                    .font(.footnote)
                    .foregroundStyle(ProgressPalette.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}
