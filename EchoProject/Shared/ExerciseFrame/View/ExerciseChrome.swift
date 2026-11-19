import SwiftUI

extension View {
    /// Navigation bar for an exercise screen: hides the tab bar and the system back
    /// button, and shows a round back button that asks the ViewModel first.
    ///
    /// The ViewModel decides what back means. During practice it calls
    /// `router.presentLeavePractice()`, so RootView shows the shared
    /// "Leave this practice?" overlay; on an error screen it can simply go back.
    ///
    ///     WordsPracticeView(…)
    ///         .exerciseChrome(onBack: vm.didTapBack)
    ///
    /// Use this for screens with their own layout; `ExerciseScaffold` gives the full
    /// Listening frame (background, back button and centred title) instead.
    func exerciseChrome(showsBack: Bool = true, onBack: @escaping () -> Void) -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                if showsBack {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back", systemImage: "chevron.left", action: onBack)
                    }
                }
            }
    }
}
