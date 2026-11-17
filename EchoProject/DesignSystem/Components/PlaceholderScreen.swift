import SwiftUI

/// Stand-in for a screen that is not built yet. Every Route shows one of these
/// until its owner replaces it, so the shell is clickable from day 1.
struct PlaceholderScreen: View {
    let title: String
    let owner: String
    var note: String? = nil

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(EchoFont.title1)
                .foregroundStyle(EchoColor.ink)
            Text("Owner: \(owner)")
                .font(EchoFont.subhead)
                .foregroundStyle(EchoColor.ink.opacity(0.7))
            if let note {
                Text(note)
                    .font(EchoFont.caption)
                    .foregroundStyle(EchoColor.ink.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(EchoColor.background)
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        PlaceholderScreen(title: "Quick Check", owner: "Dev A", note: "8 questions")
    }
}
