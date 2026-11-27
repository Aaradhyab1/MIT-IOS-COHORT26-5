import SwiftUI

/// Listening tab home: greeting, Today's practice, this level's categories,
/// games to replay, and the next level (locked).
/// Figma: Precoding_FINAL › 03 v3 · Home › Home · Listening.
struct ListeningHomeView: View {
    @State private var vm: ListeningHomeViewModel

    init(vm: ListeningHomeViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: EchoSpacing.section) {
                HomeGreetingRow(greeting: vm.greeting, onProfile: vm.didTapProfile)
                    .padding(.horizontal, EchoSpacing.screenHorizontal)

                if let practice = vm.todaysPractice {
                    TodayPracticeCard(practice: practice, onStart: vm.didTapStart) {
                        EchoHeroArt()
                    }
                    .padding(.horizontal, EchoSpacing.screenHorizontal)
                }

                VStack(spacing: EchoSpacing.m) {
                    EchoSectionHeader(
                        title: vm.levelTitle,
                        subtitle: vm.levelSubtitle,
                        actionTitle: "See all",
                        action: vm.didTapSeeAll
                    )
                    CategoryTilesRow(groups: vm.categories, onSelect: vm.didTapGroup)
                }
                .padding(.horizontal, EchoSpacing.screenHorizontal)

                if !vm.reviewCards.isEmpty {
                    VStack(spacing: EchoSpacing.m) {
                        EchoSectionHeader(title: "Practise what you've learned", subtitle: vm.reviewSubtitle)
                            .padding(.horizontal, EchoSpacing.screenHorizontal)
                        ReviewCarousel(groups: vm.reviewCards, onSelect: vm.didTapGroup)
                    }
                }

                if let upNext = vm.upNext {
                    EchoLockedCard(eyebrow: upNext.eyebrow, title: upNext.title,
                                   detail: upNext.detail, imageName: upNext.imageName)
                        .padding(.horizontal, EchoSpacing.screenHorizontal)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, EchoSpacing.xxl)
        }
        .echoScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: vm.refresh)
    }
}

#Preview {
    let container = AppContainer.dummy(startPastOnboarding: true)
    return NavigationStack {
        ListeningHomeView(vm: container.makeListeningHomeViewModel())
    }
    .environment(container)
    .environment(container.router)
}
