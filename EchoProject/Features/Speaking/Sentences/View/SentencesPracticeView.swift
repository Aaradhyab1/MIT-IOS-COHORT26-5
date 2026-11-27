import SwiftUI
import UIKit    // UIApplication.openSettingsURLString

/// Sentences practice: read aloud while each word lights up, tap a word to hear it.
/// Figma: Precoding_FINAL › 13 · Speech — Paragraphs.
/// Layout only; every decision lives in SentencesPracticeViewModel.
struct SentencesPracticeView: View {
    @State private var vm: SentencesPracticeViewModel
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(vm: SentencesPracticeViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let position = vm.positionText {
                Text(position)
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.speakingBody)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, EchoSpacing.screenHorizontal)
            }

            ScrollView {
                VStack(spacing: 20) {
                    passage
                    controls
                }
                .padding(.horizontal, EchoSpacing.screenHorizontal + 4)
                .padding(.top, 20)
                .padding(.bottom, EchoSpacing.xl)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) { bottomButtons }
        .echoExerciseBackground()
        .exerciseChrome(showsBack: !isFinished, onBack: vm.didTapBack)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: vm.readCount)
        .animation(reduceMotion ? nil : .snappy(duration: 0.25), value: vm.phase)
        .sensoryFeedback(.success, trigger: vm.phase) { _, new in new == .passageDone }
        .sheet(item: $vm.selectedWord, onDismiss: vm.didCloseSheet) { word in
            PronunciationSheet(
                word: word,
                isPlaying: vm.isSayingWord,
                onHear: vm.didTapHearPronunciation,
                onClose: vm.didCloseSheet
            )
        }
        .onDisappear { vm.stopAll() }
    }

    private var isFinished: Bool {
        if case .finished = vm.phase { return true }
        return false
    }

    // MARK: - Leo and the passage (Figma "Reading content")

    private var passage: some View {
        ReadingPassageCard(words: vm.words, highlight: vm.highlight(for:), onTapWord: vm.didTapWord)
            .padding(.top, 84)
            .overlay(alignment: .topLeading) {
                // Leo sits on the card's top edge, like the mascot in Figma.
                Image("img_leo_speaking_3d")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 104)
                    .padding(.leading, 8)
                    .accessibilityHidden(true)
            }
    }

    // MARK: - Microphone and status (Figma "Reading controls")

    private var controls: some View {
        VStack(spacing: 12) {
            if vm.showsMicrophone {
                SpeakingControlButton(control: .microphone, action: vm.didTapMicrophone)
                    .symbolEffect(.pulse, isActive: vm.isReading && !reduceMotion)
                    .accessibilityLabel(vm.isReading ? "Pause reading" : "Read aloud")
            }
            if let status = vm.status {
                Text(status)
                    .echoFont(.body, .semibold)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .contentTransition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Bottom buttons

    @ViewBuilder
    private var bottomButtons: some View {
        VStack(spacing: EchoSpacing.m) {
            switch vm.phase {
            case .passageDone:
                Button(vm.isLastPassage ? "Finish" : "Next sentence", action: vm.didTapNext)
                    .buttonStyle(.echoPrimary)
            case .micDenied:
                Button("Try microphone again", action: vm.startReading)
                    .buttonStyle(.echoPrimary)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
                .buttonStyle(.speakingSecondary)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, EchoSpacing.l)
    }
}

/// Whole Sentences flow in the canvas with the pretend reader, which reads one word
/// every half second. Run the app to use the real microphone.
private struct SentencesFlowPreview: View {
    @State private var container = AppContainer.dummy(startPastOnboarding: true)

    var body: some View {
        @Bindable var router = container.router
        NavigationStack(path: $router.speakingPath) {
            RouteDestinationView(route: .exercise(exerciseId: "sentences.short-stories"))
                .navigationDestination(for: Route.self) { route in
                    RouteDestinationView(route: route)
                }
        }
        .environment(container)
        .environment(container.router)
    }
}

#Preview("Sentences · full flow") {
    SentencesFlowPreview()
}
