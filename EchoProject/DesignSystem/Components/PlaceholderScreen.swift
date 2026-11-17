import SwiftUI

/// Temporary stand-in for a screen that has not been built yet.
///
/// Every route shows one until its real screen is implemented, so the app can be
/// navigated end to end from the start. Delete once no route uses it.
struct PlaceholderScreen: View {
    let title: String
    let owner: String
    var note: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .echoFont(.title, .bold)
                .foregroundStyle(EchoColor.textPrimary)
            Text("Owner: \(owner)")
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.textSecondary)
            if let note {
                Text(note)
                    .echoFont(.caption)
                    .foregroundStyle(EchoColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .echoScreenBackground()
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        PlaceholderScreen(title: "Quick Check", owner: "Dev A", note: "8 questions")
    }
}
