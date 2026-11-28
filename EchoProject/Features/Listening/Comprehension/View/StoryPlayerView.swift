import SwiftUI

struct StoryPlayerView: View {
    @State private var vm: StoryPlayerViewModel

    init(vm: StoryPlayerViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        content
            .echoExerciseBackground()
            .exerciseChrome(onBack: vm.didTapBack)
            .toolbar {
                if let label = vm.questionLabel {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text(label)
                            .echoFont(.caption)
                            .foregroundStyle(EchoColor.textSecondary)
                    }
                }
                if vm.isOnStoryPage {
                    ToolbarItem(placement: .topBarTrailing) {
                        StorySpeedMenu(vm: vm)
                    }
                }
            }
            .alert("Story sound", isPresented: errorIsShown) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(vm.errorMessage ?? "")
            }
    }

    private var errorIsShown: Binding<Bool> {
        Binding(
            get: { vm.errorMessage != nil },
            set: { isShown in
                if !isShown { vm.dismissError() }
            }
        )
    }

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .loading:
            ProgressView()
        case .error(let message):
            Text(message)
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.textSecondary)
        case .listening:
            StoryPageView(vm: vm)
        case .storyFinished:
            StoryFinishedView(onContinue: vm.didTapStartQuestions)
        case .ordering:
            if let ordering = vm.ordering {
                OrderingQuestionView(vm: ordering)
            }
        case .matching:
            if let matching = vm.matching {
                MatchingQuestionView(vm: matching)
            }
        case .complete:
            // The shared completion screen is pushed on top; nothing to draw here.
            Color.clear
        }
    }
}

private struct StoryPageView: View {
    let vm: StoryPlayerViewModel

    var body: some View {
        Color.clear
            .overlay {
                if let page = vm.currentPage {
                    Image(page.image)
                        .resizable()
                        .scaledToFill()
                        .accessibilityLabel(page.text)
                }
            }
            .clipped()
            .ignoresSafeArea()
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: EchoSpacing.l) {
                StoryAudioBar(vm: vm)
                    .padding(.horizontal, 26)
                ComprehensionBottomButton(title: "Next", action: vm.didTapNext)
                    .opacity(vm.canGoNext ? 1 : 0)
                    .disabled(!vm.canGoNext)
                    .accessibilityHidden(!vm.canGoNext)
            }
        }
        .onDisappear(perform: vm.didLeaveStoryPage)
    }
}

private struct StorySpeedMenu: View {
    let vm: StoryPlayerViewModel

    private var selection: Binding<NarrationSpeed> {
        Binding(get: { vm.speed }, set: { vm.didSelectSpeed($0) })
    }

    var body: some View {
        Menu {
            Picker("Reading speed", selection: selection) {
                ForEach(NarrationSpeed.allCases) { speed in
                    Label(speed.label, systemImage: speed.symbol)
                        .tag(speed)
                }
            }
        } label: {
            Image(systemName: vm.speed.symbol)
        }
        .accessibilityLabel("Reading speed, \(vm.speed.label)")
    }
}

private struct StoryAudioBar: View {
    let vm: StoryPlayerViewModel

    private var symbol: String {
        switch vm.playback {
        case .ready, .paused: "play.fill"
        case .playing: "pause.fill"
        case .finished: "arrow.counterclockwise"
        }
    }

    private var buttonLabel: String {
        switch vm.playback {
        case .ready: "Play the story"
        case .playing: "Pause"
        case .paused: "Keep listening"
        case .finished: "Listen again"
        }
    }

    private var position: Binding<Double> {
        Binding(get: { vm.playbackFraction }, set: { vm.didDragSlider(to: $0) })
    }

    var body: some View {
        HStack(spacing: EchoSpacing.m) {
            Button(action: vm.didTapPlay) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(EchoColor.textOnAccent)
                    .frame(width: 52, height: 52)
                    .background(EchoColor.accentFill, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(buttonLabel)

            VStack(spacing: EchoSpacing.xs) {
                Slider(value: position, in: 0...1, onEditingChanged: { isEditing in
                    if !isEditing { vm.didReleaseSlider() }
                })
                .tint(EchoColor.accent)
                .accessibilityLabel("Story position")
                .accessibilityValue("\(vm.elapsedText) of \(vm.durationText)")
                HStack {
                    Text(vm.elapsedText)
                    Spacer()
                    Text(vm.durationText)
                }
                .echoFont(.caption)
                .foregroundStyle(EchoColor.textSecondary)
                .monospacedDigit()
                .padding(.horizontal, EchoSpacing.xxs)
            }
        }
        .padding(.horizontal, 17)
        .frame(maxWidth: .infinity, minHeight: 99)
        .background(ComprehensionColor.frostedCard, in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.6), lineWidth: 1))
        .echoShadow(ComprehensionColor.frostedCardShadow)
    }
}

private struct StoryFinishedView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 11) {
            Text("Great!")
                .echoFont(.title, .bold)
                .foregroundStyle(EchoColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("You've finished the story.\nNow let's answer some questions.")
                .echoFont(.body)
                .foregroundStyle(EchoColor.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
            Image("img_pip_cheer")
                .resizable()
                .scaledToFit()
                .frame(width: 296, height: 226)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 130)
        .safeAreaInset(edge: .bottom) {
            ComprehensionBottomButton(title: "Let's go", action: onContinue)
        }
    }
}

#Preview("Story, silent") {
    let container = AppContainer.dummy(startPastOnboarding: true)
    let vm = StoryPlayerViewModel(
        exerciseId: "comprehension.story.cat-and-bird",
        content: container.content,
        narrator: MockStoryNarrationService(),
        progress: container.progress,
        router: container.router
    )
    return NavigationStack {
        StoryPlayerView(vm: vm)
    }
    .environment(container)
    .environment(container.router)
}

#Preview("Story, spoken") {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        StoryPlayerView(vm: container.makeStoryPlayerViewModel(exerciseId: "comprehension.story.cat-and-bird"))
    }
    .environment(container)
    .environment(container.router)
}
