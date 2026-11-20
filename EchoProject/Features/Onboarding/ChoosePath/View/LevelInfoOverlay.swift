import SwiftUI

/// "The 4 levels": what each level practises, with an everyday example. Scrolls inside the panel.
/// Figma: "Overlay — Level information".
struct LevelInfoOverlay: View {
    let levels: [LevelGuide]
    let onClose: () -> Void

    var body: some View {
        OnboardingOverlay(
            title: "The 4 levels",
            subtitle: "How your child learns to listen, step by step",
            onClose: onClose
        ) {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(levels) { level in
                        LevelInfoCard(level: level)
                    }
                }
                .padding(.horizontal, EchoSpacing.xl)
                .padding(.top, EchoSpacing.xs)
                .padding(.bottom, 28)
            }
            .frame(maxHeight: 540)
            .padding(.top, 22)
        }
    }
}
