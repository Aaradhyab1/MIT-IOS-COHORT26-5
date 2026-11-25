import Foundation
import Observation

/// Launch screen: Echo's three-keyframe entrance, then an automatic hand-off to
/// "About your child". Tapping anywhere skips straight there.
///
/// Timing follows Figma's "Motion spec / splash" (about 3.2 s end to end):
///   entrance → reveal   after 0.15 s, moves for 0.55 s
///   reveal   → lockup   after 0.30 s, moves for 0.65 s
///   lockup   → hand-off after a 1.20 s hold, dissolves for 0.35 s
/// With Reduce Motion: one 0.30 s fade straight to the lockup, then the same hold and hand-off.
@Observable
@MainActor
final class SplashViewModel {
    enum Phase: Equatable {
        case entrance   // Figma "Launch / 01 · Logo entrance": everything hidden, Echo small
        case reveal     // "Launch / 02 · Logo reveal": Echo full size, name in place
        case lockup     // "Launch / 03 · Lockup": Echo and name lifted, sparkles on
        case handOff    // fading out
        case done       // the View now opens About your child
    }

    private(set) var phase: Phase = .entrance

    private let router: AppRouter
    private var hasHandedOff = false

    init(router: AppRouter) {
        self.router = router
    }

    /// Runs the whole animation. Called from the View's `.task`, which cancels it
    /// if the screen goes away.
    func didAppear(reduceMotion: Bool) async {
        guard phase == .entrance else { return }

        do {
            if reduceMotion {
                phase = .lockup
                try await Task.sleep(for: .seconds(1.5))    // 0.30 fade + 1.20 hold
            } else {
                try await Task.sleep(for: .seconds(0.15))
                phase = .reveal
                try await Task.sleep(for: .seconds(0.85))   // 0.55 move + 0.30 pause
                phase = .lockup
                try await Task.sleep(for: .seconds(1.85))   // 0.65 move + 1.20 hold
            }

            guard phase == .lockup else { return }          // the child tapped to skip
            phase = .handOff
            try await Task.sleep(for: .seconds(0.35))

            guard phase == .handOff else { return }
            phase = .done
        } catch {
            // The screen went away before the animation finished; nothing to do.
        }
    }

    /// "Tap anywhere to skip to About your child".
    func didTapScreen() {
        phase = .done
    }

    /// Opens About your child. The View calls this once `phase` is `.done`.
    func finishHandOff() {
        guard !hasHandedOff else { return }
        hasHandedOff = true
        router.go(.childProfile)
    }
}
