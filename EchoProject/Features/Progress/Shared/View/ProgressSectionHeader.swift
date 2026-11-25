import SwiftUI

struct ProgressSectionHeader: View {
    let title: String
    var hint: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(ProgressPalette.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let hint {
                Text(hint)
                    .font(.subheadline)
                    .foregroundStyle(ProgressPalette.textSecondary)
            }
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
