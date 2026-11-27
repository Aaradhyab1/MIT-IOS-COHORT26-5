import SwiftUI

/// Speaking tab home: greeting, Today's practice, the speech skills and Conversation time.
/// Figma: Precoding_FINAL › 03 v3 · Home › Home · Speaking.
struct SpeakingHomeView: View {
    @State private var vm: SpeakingHomeViewModel

    init(vm: SpeakingHomeViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: EchoSpacing.section) {
                HomeGreetingRow(greeting: vm.greeting, onProfile: vm.didTapProfile)
                    .padding(.horizontal, EchoSpacing.screenHorizontal)

                if let practice = vm.todaysPractice {
                    TodayPracticeCard(practice: practice, onStart: vm.didTapStart) {
                        LeoSpeakingArt()
                    }
                    .padding(.horizontal, EchoSpacing.screenHorizontal)
                }

                VStack(spacing: EchoSpacing.m) {
                    EchoSectionHeader(title: "Your speech skills", subtitle: "Pick a skill, then say it out loud.")
                        .padding(.horizontal, EchoSpacing.screenHorizontal)
                    SkillCarousel(cards: vm.skillCards, onSelect: vm.didTapSkill)
                }

                if let conversation = vm.conversation {
                    VStack(spacing: EchoSpacing.l) {
                        EchoSectionHeader(title: "Conversation time", subtitle: "Practise talking about your day.")
                        ConversationCard(info: conversation, onStart: vm.didTapStartTalking)
                    }
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
        SpeakingHomeView(vm: container.makeSpeakingHomeViewModel())
    }
    .environment(container)
    .environment(container.router)
}
