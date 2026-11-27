import SwiftUI
import UIKit    // UIApplication.openSettingsURLString

/// Conversation role-play at the ice cream shop.
/// Figma: kalp › 14 · Speech — Conversation. Draws one layout per `ConversationPhase`;
/// all decisions live in ConversationViewModel.
///
/// Pictures are not added yet: every picture has a `ConversationImageSlot` that stays
/// empty until an image with its name is added to Assets. Only the shop background is used.
struct ConversationView: View {
    @State private var vm: ConversationViewModel
    @Environment(\.openURL) private var openURL

    init(vm: ConversationViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .echoExerciseBackground(.iceCreamShop)
            .navigationTitle(vm.title)
            .exerciseChrome(onBack: vm.didTapBack)
            .onDisappear { vm.stopAll() }
    }

    @ViewBuilder
    private var content: some View {
        switch vm.phase {
        case .intro:
            ConversationIntroView(onStart: vm.didTapStart)
        case .finished:
            iceCreamReady
        case .micDenied:
            message("Allow microphone access to talk to the shopkeeper.",
                    button: "Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
        case .unavailable:
            message("Speech checking isn't available on this iPhone yet.",
                    button: "Go back", action: vm.didTapBack)
        default:
            chatView
        }
    }

    // MARK: - The conversation

    private var chatView: some View {
        VStack(spacing: EchoSpacing.m) {
            Text(vm.turnText)
                .echoFont(.caption, .semibold)
                .foregroundStyle(EchoColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            ShopkeeperBubble(line: vm.shopkeeperLine, onHearAgain: vm.didTapHearAgain)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, EchoSpacing.m)

            if let childLine = vm.childLine {
                childBubble(childLine)
            }

            ZStack(alignment: .bottom) {
                // Picture slot: the shopkeeper behind the counter (Figma: 402 × 396).
                ConversationImageSlot(imageName: vm.shopkeeperImageName)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                roundControl
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            ChoiceChipsRow(choices: vm.choices)
            bottom
        }
        .padding(.horizontal, EchoSpacing.screenHorizontal)
        .padding(.bottom, EchoSpacing.xl)
        .animation(.easeInOut, value: vm.shopkeeperLine)
    }

    /// The child's last answer, on the right like a chat message.
    private func childBubble(_ text: String) -> some View {
        VStack(alignment: .trailing, spacing: EchoSpacing.xxs) {
            Text("YOU")
                .echoFont(.caption, .semibold)
                .foregroundStyle(EchoColor.textOnAccent.opacity(0.8))
            Text(text)
                .echoFont(.body, .bold)
                .foregroundStyle(EchoColor.textOnAccent)
        }
        .padding(.horizontal, EchoSpacing.l)
        .padding(.vertical, EchoSpacing.s)
        .background(EchoColor.accentFill, in: .rect(cornerRadius: 22))
        .frame(maxWidth: .infinity, alignment: .trailing)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("You said \(text)")
    }

    /// The only recording control: blue microphone to start, red stop button to finish.
    @ViewBuilder
    private var roundControl: some View {
        switch vm.phase {
        case .preparing, .checking:
            ProgressView()
                .controlSize(.large)
                .frame(height: 80)
        case .recording:
            SpeakingControlButton(control: .stop, action: vm.didTapStop)
        case .shopkeeperTalking:
            SpeakingControlButton(control: .microphone, action: vm.didTapSpeak)
                .opacity(0.5)
                .disabled(true)
        default:
            SpeakingControlButton(control: .microphone, action: vm.didTapSpeak)
        }
    }

    /// Text at the bottom, which changes with each step.
    @ViewBuilder
    private var bottom: some View {
        VStack(spacing: EchoSpacing.s) {
            if let notice = vm.notice {
                Text(notice)
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.speakingBody)
                    .multilineTextAlignment(.center)
            }

            switch vm.phase {
            case .recording:
                Text("Tap the red button when you're done.")
                    .echoFont(.body)
                    .foregroundStyle(EchoColor.speakingBody)
            case .checking:
                Text("Checking…")
                    .echoFont(.body)
                    .foregroundStyle(EchoColor.speakingBody)
            case .shopkeeperTalking:
                Text("Listen to the shopkeeper…")
                    .echoFont(.body)
                    .foregroundStyle(EchoColor.speakingBody)
            default:
                tapToSpeakCapsule
            }
        }
        .frame(minHeight: 58)
    }

    /// Glass capsule: "Tap to speak" / "Tell the shopkeeper what you would like."
    private var tapToSpeakCapsule: some View {
        Button(action: vm.didTapSpeak) {
            VStack(spacing: EchoSpacing.xxs) {
                Text("Tap to speak")
                    .echoFont(.supporting, .bold)
                    .foregroundStyle(EchoColor.accent)
                Text(vm.prompt)
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.textSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.vertical, EchoSpacing.s)
            .padding(.horizontal, EchoSpacing.l)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Capsule())
    }

    // MARK: - The end

    /// "Here you go! Your ice cream is ready." with the ice cream the child ordered.
    private var iceCreamReady: some View {
        VStack(spacing: EchoSpacing.l) {
            // Picture slot: the ice cream made from the choices, e.g.
            // "img_icecream_chocolate_cone_sprinkles".
            ConversationImageSlot(imageName: vm.iceCreamImageName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: EchoSpacing.s) {
                Text("Here you go!")
                    .echoFont(.title, .bold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("Your ice cream is ready.")
                    .echoFont(.subheading, .semibold)
                    .foregroundStyle(EchoColor.textPrimary)
                ChoiceChipsRow(choices: vm.order)
                    .padding(.top, EchoSpacing.xs)
            }
            .multilineTextAlignment(.center)
            .padding(EchoSpacing.l)
            .frame(maxWidth: .infinity)
            .glassEffect(.regular, in: .rect(cornerRadius: 28))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Here you go! Your ice cream is ready: \(vm.orderSummary).")

            Button("Back to home", action: vm.didTapDone)
                .buttonStyle(.echoPrimary)
        }
        .padding(.horizontal, EchoSpacing.screenHorizontal)
        .padding(.bottom, EchoSpacing.xl)
    }

    // MARK: - Recovery

    private func message(_ text: String, button: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: EchoSpacing.l) {
            Spacer()
            Text(text)
                .echoFont(.body)
                .foregroundStyle(EchoColor.speakingBody)
                .multilineTextAlignment(.center)
            Button(button, action: action)
                .buttonStyle(.echoPrimary)
            Spacer()
        }
        .padding(.horizontal, EchoSpacing.screenHorizontal)
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        ConversationView(vm: container.makeConversationViewModel(exerciseId: "conversation.ice-cream-shop"))
    }
    .environment(container)
    .environment(container.router)
}
