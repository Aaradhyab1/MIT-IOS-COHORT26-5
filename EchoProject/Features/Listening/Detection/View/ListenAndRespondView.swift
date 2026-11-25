import SwiftUI

/// Detection screen: cloud, speech bubble, then Play / "I heard it" / Next.
/// Layout only; every decision lives in ListenAndRespondViewModel.
struct ListenAndRespondView: View {
    @State private var vm: ListenAndRespondViewModel

    init(vm: ListenAndRespondViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ExerciseScaffold(title: vm.title, subtitle: vm.subtitle, onBack: vm.backTapped) {
            // Positions below the heading come straight from the Figma frames:
            // scene at 0, speech bubble at 352, buttons at 472.
            ZStack(alignment: .top) {
                scene
                bubble
                    .padding(.top, 352)
                controls
                    .padding(.top, 472)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onDisappear { vm.stopAll() }
    }

    // MARK: - Scene (Figma "Scene / Hidden" and "Scene / Reveal", 362 × 320)

    @ViewBuilder
    private var scene: some View {
        if vm.revealIncludesCloud, let image = vm.revealImage {
            // "Bunny and cloud (cutout)": one picture with its own cloud, nothing behind it.
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 340, height: 315)
                .frame(width: 362, height: 320)
                .accessibilityLabel(vm.title)
        } else {
            ZStack(alignment: .top) {
                Image("img_cloud_shadow")
                    .padding(.top, 217)

                if let image = vm.revealImage {
                    // The animal peeks out from behind the cloud.
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 214)
                        .offset(y: -40)
                        .accessibilityLabel(vm.title)
                }

                Image("img_cloud")
                    .padding(.top, vm.revealImage == nil ? 113 : 137)
                    .accessibilityHidden(true)
            }
            .frame(width: 362, height: 260, alignment: .top)
            .padding(.top, 60)
            .frame(height: 320, alignment: .top)
        }
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
