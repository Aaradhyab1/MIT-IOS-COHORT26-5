import Foundation
import Observation

/// "Leave this practice?" — the confirmation shown over an exercise when the child taps close.
///
/// An exercise opens it with `router.presentLeavePractice()`; RootView draws it on top
/// of everything while `router.overlay == .leavePractice`.
@Observable
@MainActor
final class LeavePracticeViewModel {
    private let audio: any AudioPlaybackService
    private let router: AppRouter

    init(audio: any AudioPlaybackService, router: AppRouter) {
        self.audio = audio
        self.router = router
    }

    /// Closes the overlay; the exercise carries on where it was.
    func keepPractising() {
        router.dismissOverlay()
    }

    /// Stops any sound, closes the overlay and goes back to where the exercise was started from.
    func leave() {
        audio.stop()
        router.leavePractice()
    }
}
