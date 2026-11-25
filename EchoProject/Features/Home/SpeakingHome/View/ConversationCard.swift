import SwiftUI

/// "Conversation time": the ice cream shop picture, "SPEAK TOGETHER", and a Start talking button.
struct ConversationCard: View {
    let info: ConversationInfo
    let onStart: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            EchoArtwork(imageName: info.imageName, cornerRadius: 20)
                .frame(width: 124, height: 124)
            VStack(alignment: .leading, spacing: EchoSpacing.xs) {
                Text("SPEAK TOGETHER")
                    .echoFont(.caption, .semibold)
                    .foregroundStyle(EchoColor.accent)
                Text(info.title)
                    .echoFont(.body, .semibold)
                    .foregroundStyle(EchoColor.textPrimary)
                Text(info.detail)
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.textSecondary)
                Button("Start talking", action: onStart)
                    .echoFont(.supporting, .semibold)
                    .foregroundStyle(EchoColor.accent)
                    .padding(.horizontal, EchoSpacing.l)
                    .padding(.vertical, EchoSpacing.m)
                    .background(EchoColor.symbolTile, in: Capsule())
                    .buttonStyle(.plain)
                    .padding(.top, EchoSpacing.xs)
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, EchoSpacing.m)
        .padding(.trailing, 14)
        .padding(.vertical, EchoSpacing.m)
        .echoCard(cornerRadius: EchoRadius.cardLarge)
    }
}
