import SwiftUI

/// Identification game: hear a sound, tap the picture that made it.
/// Figma: edit_cl › 08 · Level 3 — Instruments, 09 · Level 3 — Animals. Layout only; decisions live in the ViewModel.
struct PictureChoiceView: View {
    @State private var vm: PictureChoiceViewModel

    init(vm: PictureChoiceViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        Group {
            if let learning = vm.learning {
                LearnSoundsView(vm: learning)
                    .transition(.opacity)
            } else {
                game
                    .transition(.opacity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .animation(.easeInOut(duration: 0.3), value: vm.learning == nil)
        .onDisappear { vm.stopAll() }
    }

    // MARK: - Game

    private var game: some View {
        ZStack {
            meadow

            // Positions below come from the Figma frames (status bar ends at 62):
            // back button and progress at 66, play button at 164, question at 250, helper at 298.
            VStack(spacing: 0) {
                header
                    .padding(.top, 4)

                audioButton
                    .frame(height: 64)
                    .padding(.top, 48)

                Text(vm.title)
                    .echoFont(.heading, .bold)
                    .foregroundStyle(Color(hex: 0x181F2F))
                    .padding(.top, 22)

                Text(vm.helper)
                    .echoFont(.supporting, .semibold)
                    .foregroundStyle(helperColor)
                    .padding(.top, 20)

                Spacer(minLength: 0)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, EchoSpacing.screenHorizontal)
        }
        .animation(.easeInOut(duration: 0.25), value: vm.phase)
    }

    // MARK: - Header (Figma "Navigation")

    private var header: some View {
        HStack {
            EchoIconButton(systemImage: "chevron.left", accessibilityLabel: "Back", action: vm.backTapped)
            Spacer()
            Text(vm.progressText)
                .echoFont(.supporting)
                .foregroundStyle(EchoColor.textPrimary)
        }
        .frame(height: 50)
    }

    // MARK: - Play / listening / replay (Figma "Audio Controller")

    @ViewBuilder
    private var audioButton: some View {
        switch vm.audioControl {
        case .listening:
            ListeningWaveform()
                .accessibilityLabel("Listening")
        case .play, .replay:
            Button(action: vm.playTapped) {
                Image(systemName: vm.audioControl == .play ? "play.fill" : "arrow.counterclockwise")
                    .font(.system(size: 24, weight: .semibold))
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .controlSize(.large)
            .disabled(!vm.canPlay)
            .accessibilityLabel(vm.audioControl == .play ? "Play the sound" : "Play the sound again")
        }
    }

    private var helperColor: Color {
        switch vm.helperTone {
        case .normal: return EchoColor.textPrimary
        case .wrong: return Color(hex: 0xD70015)
        case .correct: return Color(hex: 0x248A3D)
        }
    }

    // MARK: - Meadow with the pictures

    /// The pictures standing on their mats; MeadowCanvas scales it all to the screen.
    private var meadow: some View {
        MeadowCanvas {
            ForEach(vm.pictures) { picture in
                GroundView(ground: picture.ground)
            }
            ForEach(vm.pictures) { picture in
                pictureButton(picture).placed(in: picture.artFrame)
            }
        }
    }

    private func pictureButton(_ picture: PictureChoiceViewModel.Picture) -> some View {
        Button {
            vm.pictureTapped(picture.id)
        } label: {
            if let art = picture.art {
                ZStack {
                    if let color = outlineColor(picture.highlight) {
                        OutlineBehind(art: art, color: color)
                    }
                    Image(art)
                        .resizable()
                        .scaledToFit()
                }
            } else {
                // Art not drawn yet: the name stands on the mat instead.
                Text(picture.label)
                    .echoFont(.body, .semibold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .padding(.horizontal, EchoSpacing.m)
                    .padding(.vertical, EchoSpacing.s)
                    .background(.white.opacity(0.8), in: Capsule())
                    .overlay(Capsule().stroke(outlineColor(picture.highlight) ?? .clear, lineWidth: 3))
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .buttonStyle(.plain)
        .allowsHitTesting(picture.canTap)
        .accessibilityLabel(picture.label)
    }

    private func outlineColor(_ highlight: PictureChoiceViewModel.Picture.Highlight) -> Color? {
        switch highlight {
        case .none: return nil
        case .wrong: return Color(hex: 0xFF3B30)
        case .correct: return Color(hex: 0x34C759)
        }
    }
}

/// Blue bars that bounce while the sound plays (Figma "Waveform", 148 × 56).
private struct ListeningWaveform: View {
    private let heights: [CGFloat] = [14, 24, 38, 26, 46, 32, 56, 40, 50, 40, 56, 32, 46, 26, 38, 24, 14]
    @State private var bouncing = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(heights.indices, id: \.self) { index in
                Capsule()
                    .fill(Color(hex: 0x007AFF))
                    .frame(width: 4, height: heights[index])
                    .scaleEffect(y: bouncing ? 1 : 0.45)
                    .animation(
                        .easeInOut(duration: 0.45)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index % 5) * 0.08),
                        value: bouncing
                    )
            }
        }
        .frame(width: 148, height: 56)
        .onAppear { bouncing = true }
    }
}

// MARK: - Previews

/// Whole Instruments flow in the canvas: Play → pick → completion screen.
/// Uses the real router stack. The leave overlay is drawn by RootView, so run the app to see it.
private struct IdentificationFlowPreview: View {
    var exerciseId = "identification.instruments"
    @State private var container = AppContainer.dummy(startPastOnboarding: true)

    var body: some View {
        @Bindable var router = container.router
        NavigationStack(path: $router.listeningPath) {
            RouteDestinationView(route: .exercise(exerciseId: exerciseId))
                .navigationDestination(for: Route.self) { route in
                    RouteDestinationView(route: route)
                }
        }
        .environment(container)
        .environment(container.router)
    }
}

#Preview("Identification · Instruments") {
    IdentificationFlowPreview()
}

#Preview("Identification · Animals") {
    IdentificationFlowPreview(exerciseId: "identification.animals")
}
