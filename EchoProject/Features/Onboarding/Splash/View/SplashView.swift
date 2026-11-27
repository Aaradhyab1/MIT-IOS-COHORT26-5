import SwiftUI

/// Launch screen: Echo arrives on his grass mound, the name settles under him,
/// then the screen dissolves into About your child.
/// Figma: Precoding_FINAL › 01 · App launch (3 keyframes + "Motion spec / splash").
struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var vm: SplashViewModel

    /// Side of the square Echo stands in ("Echo art", 210.6 pt in Figma).
    private let artSize: CGFloat = 210

    init(vm: SplashViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        VStack(spacing: 48) {
            artwork
            wordmark
        }
        .offset(y: -20)   // the lockup sits a little above the middle of the screen
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(isFadedOut ? 0 : 1)
        .contentShape(Rectangle())
        .onTapGesture(perform: vm.didTapScreen)
        .animation(animation, value: vm.phase)
        .echoScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Echo")
        .accessibilityHint("Double-tap to continue")
        .accessibilityAddTraits(.isButton)
        .task {
            await vm.didAppear(reduceMotion: reduceMotion)
        }
        .onChange(of: vm.phase) { _, newPhase in
            guard newPhase == .done else { return }
            // Open About your child without the usual slide, so the hand-off reads as a dissolve.
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                vm.finishHandOff()
            }
        }
    }

    // MARK: - Pieces

    /// Glow, Echo on his grass mound, and the two sparkles.
    private var artwork: some View {
        ZStack {
            // The glow has its own size in each keyframe, so it is not scaled with Echo.
            Circle()
                .fill(RadialGradient(colors: [.white, .white.opacity(0)], center: .center,
                                     startRadius: 0, endRadius: glowSize * 0.65))
                .frame(width: glowSize * 1.3, height: glowSize * 1.3)

            ZStack(alignment: .topLeading) {
                // Figma "Echo art": Echo with his grass mound, exported as one transparent picture.
                // It is 372 × 235 pt and starts 81 pt left of and 6 pt above the 210 pt square.
                EchoAssetImage(name: "img_echo_art")
                    .frame(width: 372, height: 235)
                    .offset(x: -81, y: -6)

                sparkle(size: 18, color: EchoColor.Paper.sunshine)
                    .offset(x: 0, y: 33)
                sparkle(size: 12, color: EchoColor.Paper.lightBlue)
                    .offset(x: 204, y: -3)
            }
            .frame(width: artSize, height: artSize, alignment: .topLeading)
            .scaleEffect(layout == .entrance ? 0.533 : 1)
            .opacity(vm.phase == .entrance ? 0 : 1)
        }
        .frame(width: artSize, height: artSize)
        .offset(y: artOffset)
    }

    private var wordmark: some View {
        Text("Echo")
            .font(.system(size: 44, weight: .bold, design: .rounded))
            .foregroundStyle(EchoColor.textPrimary)
            .opacity(vm.phase == .entrance ? 0 : 1)
            .offset(y: wordmarkOffset)
    }

    private func sparkle(size: CGFloat, color: Color) -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: size))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .opacity(layout == .lockup ? 1 : 0)
    }

    // MARK: - Values per keyframe

    /// Reduce Motion skips all movement: everything is laid out as the final lockup
    /// from the start and only fades in.
    private var layout: SplashViewModel.Phase {
        if reduceMotion { return .lockup }
        switch vm.phase {
        case .entrance, .reveal: return vm.phase
        case .lockup, .handOff, .done: return .lockup
        }
    }

    private var isFadedOut: Bool {
        vm.phase == .handOff || vm.phase == .done
    }

    /// Glow diameter in Figma: 140 → 300 → 320.
    private var glowSize: CGFloat {
        switch layout {
        case .entrance: 140
        case .reveal: 300
        default: 320
        }
    }

    /// Echo starts 64 pt lower, then the lockup lifts him 26 pt.
    private var artOffset: CGFloat {
        switch layout {
        case .entrance: 64
        case .reveal: 0
        default: -26
        }
    }

    /// The name rises 28 pt into place, then lifts 26 pt with Echo.
    private var wordmarkOffset: CGFloat {
        switch layout {
        case .entrance: 28
        case .reveal: 0
        default: -26
        }
    }

    /// Ease-out curve (0.22, 1, 0.36, 1) from the motion spec, with each step's length.
    private var animation: Animation {
        switch vm.phase {
        case .handOff: .easeOut(duration: 0.35)
        case _ where reduceMotion: .easeOut(duration: 0.3)
        case .reveal: .timingCurve(0.22, 1, 0.36, 1, duration: 0.55)
        case .lockup: .timingCurve(0.22, 1, 0.36, 1, duration: 0.65)
        default: .default
        }
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: false)
    return NavigationStack {
        SplashView(vm: container.makeSplashViewModel())
    }
    .environment(container)
    .environment(container.router)
}
