import SwiftUI

/// Detection screen: speech bubble, the bush the animal hides behind, then Play / "I heard it" / Next.
/// Layout only; every decision lives in ListenAndRespondViewModel.
struct ListenAndRespondView: View {
    @State private var vm: ListenAndRespondViewModel

    init(vm: ListenAndRespondViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ExerciseScaffold(title: vm.title, subtitle: vm.subtitle, onBack: vm.backTapped) {
            // Positions below the heading come straight from the Figma frames:
            // speech bubble at 14, bush standing on the hill at 290, buttons at 472.
            ZStack(alignment: .top) {
                scene
                bubble
                    .padding(.top, 14)
                controls
                    .padding(.top, 472)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onDisappear { vm.stopAll() }
    }

    // MARK: - Scene (Figma "Hiding spot / Bush")

    /// The bush stands on the green hill of the background. It never moves while the
    /// sound plays, so the child answers from what they heard, not from what they saw.
    /// After the answer the animal rises up from behind it; on Next it just fades away.
    private var scene: some View {
        ZStack(alignment: .top) {
            // Clipped just below the bush, so while the animal is still low
            // it stays hidden behind the bush instead of showing underneath it.
            ZStack(alignment: .top) {
                if let image = vm.revealImage {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 160, alignment: .bottom)
                        .padding(.top, 200)
                        .transition(.asymmetric(
                            insertion: .offset(y: 120),     // starts hidden behind the bush, rises up
                            removal: .opacity               // leaves without sliding back down
                        ))
                        .accessibilityLabel(vm.title)
                }
            }
            .frame(width: 362, height: 400, alignment: .top)
            .clipped()

            Image("img_hide_bush")
                .padding(.top, 290)
                .accessibilityHidden(true)
        }
        .frame(width: 362, alignment: .top)
        .animation(.spring(duration: 0.5, bounce: 0.25), value: vm.revealImage)
    }

    // MARK: - Speech bubble (Figma "Encouragement")

    @ViewBuilder
    private var bubble: some View {
        if let title = vm.bubbleTitle {
            VStack(spacing: EchoSpacing.xs) {
                Text(title)
                    .echoFont(.body, .semibold)
                    .foregroundStyle(EchoColor.textPrimary)
                if let detail = vm.bubbleDetail {
                    Text(detail)
                        .echoFont(.supporting)
                        .foregroundStyle(EchoColor.textTertiary)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.vertical, EchoSpacing.l)
            .padding(.horizontal, EchoSpacing.xl)
            .frame(width: 280)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30))
            .background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 30))
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(.white.opacity(0.8), lineWidth: 2))
            .shadow(color: Color(hex: 0x14334D, opacity: 0.14), radius: 12, y: 8)
        }
    }

    // MARK: - Buttons (Figma "Actions")

    @ViewBuilder
    private var controls: some View {
        switch vm.phase {
        case .ready, .playing:
            VStack(spacing: EchoSpacing.xs) {
                Button {
                    vm.playTapped()
                } label: {
                    Image(systemName: vm.phase == .playing ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .controlSize(.large)
                .accessibilityLabel(vm.phase == .playing ? "Pause" : "Play")

                if vm.phase == .playing {
                    Text("Pause")
                        .echoFont(.caption, .semibold)
                        .foregroundStyle(EchoColor.textPrimary)
                }
            }

        case .asking:
            VStack(spacing: 14) {
                Button {
                    vm.answer(heardIt: true)
                } label: {
                    Text("I Heard It")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)

                Button {
                    vm.answer(heardIt: false)
                } label: {
                    Text("I Didn’t Hear It")
                        .foregroundStyle(EchoColor.textPrimary)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
            .controlSize(.large)
            .frame(width: 280)

        case .reveal:
            Button {
                vm.nextTapped()
            } label: {
                Text("Next")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .frame(width: 280)
        }
    }
}

/// Whole Detection flow in the canvas: Play → answer → Next → … → completion screen.
/// Uses the real router stack so Next and Try Again work. The leave overlay is drawn by
/// RootView, so run the app to see it.
private struct DetectionFlowPreview: View {
    @State private var container = AppContainer.dummy(startPastOnboarding: true)

    var body: some View {
        @Bindable var router = container.router
        NavigationStack(path: $router.listeningPath) {
            RouteDestinationView(route: .exercise(exerciseId: "detection.hide-and-seek.animal"))
                .navigationDestination(for: Route.self) { route in
                    RouteDestinationView(route: route)
                }
        }
        .environment(container)
        .environment(container.router)
    }
}

#Preview("Detection · full flow") {
    DetectionFlowPreview()
}
