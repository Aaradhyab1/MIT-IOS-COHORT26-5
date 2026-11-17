import SwiftUI

/// Heading for a section of a scrolling screen: a title, an optional subtitle,
/// and an optional trailing link such as "See all".
///
///     EchoSectionHeader(
///         title: "Practise what you've learned",
///         subtitle: "Replay games from Levels 1 and 2.",
///         actionTitle: "See all",
///         action: viewModel.showAll
///     )
struct EchoSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    /// The link is shown only when both `actionTitle` and `action` are provided.
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: EchoSpacing.xs) {
                Text(title)
                    .echoFont(.subheading, .semibold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                if let subtitle {
                    Text(subtitle)
                        .echoFont(.supporting)
                        .foregroundStyle(EchoColor.textSecondary)
                }
            }
            Spacer(minLength: EchoSpacing.s)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .echoFont(.supporting, .semibold)
                    .tint(EchoColor.accent)
            }
        }
    }
}
