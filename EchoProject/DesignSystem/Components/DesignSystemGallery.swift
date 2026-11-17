import SwiftUI

/// Preview-only catalogue of every design token and shared component.
///
/// Open the canvas (Editor ▸ Canvas) to compare against Figma after changing a token.
/// The "Large text" preview renders at an accessibility Dynamic Type size to check that
/// layouts still work for parents who use bigger text.
private struct DesignSystemGallery: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: EchoSpacing.section) {
                typeScale
                heroCard
                EchoSectionHeader(
                    title: "Level 3 - Identify more sounds",
                    subtitle: "Pick a category, then name what you hear.",
                    actionTitle: "See all",
                    action: {}
                )
                HStack {
                    EchoCategoryTile(title: "Animals", detail: "4 of 10", imageName: "",
                                     progress: 0.4, isCurrent: true, action: {})
                    Spacer()
                    EchoCategoryTile(title: "Nature", detail: "New", imageName: "", action: {})
                }
                HStack(spacing: EchoSpacing.m) {
                    EchoExerciseCard(title: "Hide & Seek", meta: "Level 1 · 4 min", imageName: "", action: {})
                    EchoExerciseCard(title: "Name Alert", meta: "Level 1 · 3 min", imageName: "", action: {})
                }
                EchoLockedCard(eyebrow: "Up next · Level 4", title: "Understand sounds",
                               detail: "Play 6 more games to unlock.", imageName: "")
                EchoIconButton(systemImage: "person.fill", accessibilityLabel: "Profile", action: {})
            }
            .padding(.horizontal, EchoSpacing.screenHorizontal)
            .padding(.vertical, EchoSpacing.xl)
        }
        .echoScreenBackground()
    }

    private var typeScale: some View {
        VStack(alignment: .leading, spacing: EchoSpacing.xs) {
            Text("Display 34").echoFont(.display, .bold)
            Text("Title 28").echoFont(.title, .bold)
            Text("Heading 22").echoFont(.heading, .bold)
            Text("Subheading 20").echoFont(.subheading, .semibold)
            Text("Body 17").echoFont(.body)
            Text("Supporting 15").echoFont(.supporting)
            Text("Caption 13").echoFont(.caption)
        }
        .foregroundStyle(EchoColor.textPrimary)
    }

    private var heroCard: some View {
        VStack(spacing: EchoSpacing.m) {
            EchoLevelBadge(level: 3, text: "You're at Level 3")
            HStack {
                EchoMetaPill(text: "5 min", systemImage: "clock")
                EchoMetaPill(text: "10 sounds")
            }
            Button("Start") {}
                .buttonStyle(.echoPrimary)
            Button("Start (disabled)") {}
                .buttonStyle(.echoPrimary)
                .disabled(true)
        }
        .padding(EchoSpacing.xl)
        .echoHeroCard()
    }
}

/// Shows the exercise backdrop with sample content on top.
private struct ExerciseBackgroundPreview: View {
    let backdrop: EchoBackdrop

    var body: some View {
        VStack {
            Spacer()
            Button("I heard it") {}
                .buttonStyle(.echoPrimary)
                .padding(EchoSpacing.screenHorizontal)
        }
        .echoExerciseBackground(backdrop)
    }
}

#Preview("Design system") { DesignSystemGallery() }
#Preview("Large text") { DesignSystemGallery().dynamicTypeSize(.accessibility2) }
#Preview("Exercise background") { ExerciseBackgroundPreview(backdrop: .landscape) }
#Preview("Conversation background") { ExerciseBackgroundPreview(backdrop: .iceCreamShop) }
