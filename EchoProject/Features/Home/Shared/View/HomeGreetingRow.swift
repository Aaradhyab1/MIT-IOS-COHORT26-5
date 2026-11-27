import SwiftUI

/// "Good morning" with the profile button on the right. Top of both home tabs.
struct HomeGreetingRow: View {
    let greeting: String
    let onProfile: () -> Void

    var body: some View {
        HStack(spacing: EchoSpacing.m) {
            Text(greeting)
                .echoFont(.title, .bold)
                .foregroundStyle(EchoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            EchoIconButton(systemImage: "person.fill", accessibilityLabel: "Profile", action: onProfile)
        }
    }
}
