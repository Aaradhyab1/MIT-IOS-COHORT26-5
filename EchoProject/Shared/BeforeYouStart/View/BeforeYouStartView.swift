import SwiftUI

/// "Before you start": shared intro shown before every exercise.
/// Figma: "Exercise intro — Before you start · Animals (v2 template)".
struct BeforeYouStartView: View {
    /// @State keeps the same ViewModel while SwiftUI rebuilds this view.
    @State private var vm: BeforeYouStartViewModel

    init(vm: BeforeYouStartViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: EchoSpacing.xl) {
                artwork
                titleBlock
                metaPills
                howToPlay
                grownUpTip
                actions
            }
            .padding(.horizontal, EchoSpacing.screenHorizontal)
            .padding(.top, EchoSpacing.s)
            .padding(.bottom, 40)
        }
        .echoScreenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { vm.stopExample() }
    }

    // MARK: - Sections

    private var artwork: some View {
        EchoArtwork(imageName: vm.illustration, cornerRadius: 84)
            .frame(width: 168, height: 168)
            .overlay(Circle().strokeBorder(.white, lineWidth: 4))
    }

    private var titleBlock: some View {
        VStack(spacing: 6) {
            Text(vm.eyebrow)
                .echoFont(.caption, .semibold)
                .foregroundStyle(EchoColor.accent)
            Text(vm.title)
                .echoFont(.title, .bold)
                .foregroundStyle(EchoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(vm.summary)
                .echoFont(.body)
                .foregroundStyle(EchoColor.textSecondary)
        }
        .multilineTextAlignment(.center)
    }

    /// "5 min", "10 sounds", "Headphones on" as light blue capsules.
    private var metaPills: some View {
        HStack(spacing: 6) {
            ForEach(vm.metaPills, id: \.self) { text in
                Text(text)
                    .echoFont(.caption, .semibold)
                    .foregroundStyle(EchoColor.accent)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(EchoColor.pillSurfaceTinted, in: Capsule())
            }
        }
    }

    private var howToPlay: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How to play")
                .echoFont(.body, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            ForEach(vm.steps) { step in
                StepRow(step: step)
            }
        }
        .padding(EchoSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .echoCard(cornerRadius: EchoRadius.cardLarge)
    }

    private var grownUpTip: some View {
        VStack(alignment: .leading, spacing: EchoSpacing.xxs) {
            Text("TIP FOR GROWN-UPS")
                .echoFont(.caption, .semibold)
                .foregroundStyle(EchoColor.tipLabel)
            Text(vm.tip)
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.textPrimary)
        }
        .padding(.vertical, EchoSpacing.m)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EchoColor.tipSurface, in: .rect(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }

    private var actions: some View {
        VStack(spacing: EchoSpacing.m) {
            Button("Start", action: vm.start)
                .buttonStyle(.echoPrimary)

            if vm.canPlayExample {
                Button(vm.isPlayingExample ? "Playing example…" : "Hear an example first") {
                    Task { await vm.playExample() }
                }
                .buttonStyle(.echoSecondary)
                .disabled(vm.isPlayingExample)
            }
        }
    }
}

/// A numbered "How to play" step: blue number badge, bold title, grey detail.
private struct StepRow: View {
    let step: ExerciseInstructions.Step

    var body: some View {
        HStack(alignment: .top, spacing: EchoSpacing.m) {
            Text(step.number, format: .number)
                .echoFont(.caption, .semibold)
                .foregroundStyle(EchoColor.textOnAccent)
                .frame(width: 28, height: 28)
                .background(EchoColor.accent, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: EchoSpacing.xxs) {
                Text(step.title)
                    .echoFont(.supporting, .semibold)
                    .foregroundStyle(EchoColor.textPrimary)
                Text(step.detail)
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(step.number): \(step.title). \(step.detail)")
    }
}

#Preview("Animals") {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        BeforeYouStartView(vm: container.makeBeforeYouStartViewModel(exerciseId: "identification.animals"))
    }
    .environment(container)
    .environment(container.router)
}

#Preview("Large text") {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        BeforeYouStartView(vm: container.makeBeforeYouStartViewModel(exerciseId: "identification.animals"))
    }
    .dynamicTypeSize(.accessibility2)
    .environment(container)
    .environment(container.router)
}
