import SwiftUI

/// "Choose a starting level": a dropdown of the 4 levels, then Continue once one is picked.
/// Figma: "Overlay — Custom level / closed", "/ open" and "/ selected 1–4".
struct CustomLevelOverlay: View {
    let vm: ChoosePathViewModel

    var body: some View {
        OnboardingOverlay(
            title: "Choose a starting level",
            subtitle: "Pick the level that fits your child",
            onClose: vm.didDismissOverlay
        ) {
            VStack(spacing: EchoSpacing.s) {
                LevelDropdownField(
                    selected: vm.selectedLevel,
                    isOpen: vm.isLevelListOpen,
                    action: vm.didTapLevelField
                )

                if vm.isLevelListOpen {
                    LevelDropdownList(levels: vm.levels, onSelect: vm.didSelectLevel)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                if vm.canContinue {
                    Button("Continue", action: vm.didTapContinue)
                        .buttonStyle(.echoPrimary)
                        .padding(.top, EchoSpacing.m)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 23)
            .padding(.top, 23)
            .padding(.bottom, 28)
            .animation(.snappy(duration: 0.25), value: vm.isLevelListOpen)
            .animation(.snappy(duration: 0.25), value: vm.selectedLevel)
        }
    }
}
