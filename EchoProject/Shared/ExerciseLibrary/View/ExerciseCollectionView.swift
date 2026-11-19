import SwiftUI

/// "Story Hide & Seek" list from the Figma frame detection-library-story-hide-seek.
struct ExerciseCollectionView: View {
    @State private var vm: ExerciseCollectionViewModel

    init(vm: ExerciseCollectionViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            EchoIconButton(systemImage: "chevron.left", accessibilityLabel: "Back") {
                vm.backTapped()
            }
            .padding(.top, EchoSpacing.m)

            Text(vm.title)
                .echoFont(.title, .bold)
                .foregroundStyle(EchoColor.textPrimary)
                .padding(.top, 26)

            ScrollView {
                VStack(spacing: EchoSpacing.m) {
                    ForEach(vm.rows) { row in
                        Button {
                            vm.rowTapped(row)
                        } label: {
                            card(for: row)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, EchoSpacing.l)
                .padding(.bottom, 160)       // room above the wave footer
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(alignment: .bottom) {
            // "Gentle Cloud Backdrop" from Figma.
            Image("img_wave_footer")
                .resizable()
                .frame(height: 170)
                .ignoresSafeArea()
                .accessibilityHidden(true)
        }
        .echoScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    /// Figma "Practice Library / Exercise card": 354 × 116, white, radius 24.
    private func card(for row: ExerciseCollectionViewModel.Row) -> some View {
        HStack(spacing: EchoSpacing.s) {
            Image(row.illustration)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .background(EchoColor.heroSurface)
                .clipShape(RoundedRectangle(cornerRadius: EchoRadius.thumbnailSmall))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(row.title)
                    .echoFont(.body, .bold)
                    .foregroundStyle(Color(hex: 0x0F172A))
                HStack(spacing: EchoSpacing.s) {
                    ProgressView(value: row.progressValue)
                        .tint(EchoColor.accent)
                    Text(row.progressText)
                        .echoFont(.caption)
                        .foregroundStyle(Color(hex: 0x59697D))
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(EchoColor.textSecondary)
        }
        .padding(.horizontal, EchoSpacing.m)
        .padding(.vertical, EchoSpacing.s)
        .frame(height: 116)
        .background(.white, in: RoundedRectangle(cornerRadius: EchoRadius.cardLarge))
        .shadow(color: Color(hex: 0x335C8C, opacity: 0.07), radius: 8, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: EchoRadius.cardLarge))
    }
}

/// Library → exercise → completion, all clickable in the canvas.
private struct HideAndSeekFlowPreview: View {
    @State private var container = AppContainer.dummy(startPastOnboarding: true)

    var body: some View {
        @Bindable var router = container.router
        NavigationStack(path: $router.listeningPath) {
            RouteDestinationView(route: .exerciseCollection(levelId: "listening.detection", collection: "Story Hide & Seek"))
                .navigationDestination(for: Route.self) { route in
                    RouteDestinationView(route: route)
                }
        }
        .environment(container)
        .environment(container.router)
    }
}

#Preview("Story Hide & Seek · full flow") {
    HideAndSeekFlowPreview()
}
