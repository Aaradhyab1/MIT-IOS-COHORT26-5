import SwiftUI

/// A level number in a light blue circle, e.g. ③.
struct LevelNumberBadge: View {
    let number: Int

    var body: some View {
        Text(number, format: .number)
            .echoFont(.body, .semibold)
            .foregroundStyle(EchoColor.accent)
            .frame(width: 32, height: 32)
            .background(EchoColor.levelBadge, in: Circle())
            .accessibilityHidden(true)
    }
}
