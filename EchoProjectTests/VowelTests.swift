import Foundation
import Testing
@testable import EchoProject

struct VowelFormantsTests {
    @Test func practisedSoundsMapToTheirFamily() {
        #expect(VowelFormants.family(of: "ɑː") == "ɑ")
        #expect(VowelFormants.family(of: "uː") == "u")
        #expect(VowelFormants.family(of: "iː") == "i")
    }

    @Test func childrensVowelsAreRecognised() {
        // Children's averages from the chart.
        #expect(VowelFormants.familyOfVowel(VowelFormants.nearestVowel(f1: 1002, f2: 1688) ?? "") == "ɑ")
        #expect(VowelFormants.familyOfVowel(VowelFormants.nearestVowel(f1: 494, f2: 1345) ?? "") == "u")
        #expect(VowelFormants.familyOfVowel(VowelFormants.nearestVowel(f1: 452, f2: 3081) ?? "") == "i")
    }

    @Test func soundsFarFromEveryVowelAreIgnored() {
        #expect(VowelFormants.nearestVowel(f1: 1250, f2: 3900) == nil)
    }
}

struct VowelTranscriptTests {
    @Test func anyLengthOfTheSameVowelReadsTheSame() {
        for text in ["a", "aa", "aaa", "Aaaaa!", "Ah", "Ahhh", "AAH", "aa aa"] {
            #expect(VowelTranscript.family(of: text) == "ɑ", "\(text)")
        }
        for text in ["oo", "Ooo", "Oooh", "ooo ooo", "Who"] {
            #expect(VowelTranscript.family(of: text) == "u", "\(text)")
        }
        for text in ["ee", "Eee", "EEEE", "ee ee"] {
            #expect(VowelTranscript.family(of: text) == "i", "\(text)")
        }
    }

    @Test func realWordsAndMixedVowelsAreNotAVowel() {
        #expect(VowelTranscript.family(of: "hello") == nil)
        #expect(VowelTranscript.family(of: "aa ee") == nil)
        #expect(VowelTranscript.family(of: "") == nil)
    }

    private let unsure = VowelCheck(isMatch: false, heard: nil, matchingSeconds: 0)

    @Test func theRecognisersAaaCountsForPlane() {
        let result = VowelTranscript.decide(formants: unsure, transcripts: ["Aaa"], target: "ɑ")
        #expect(result.isMatch)
    }

    @Test func aDifferentVowelIsStillRejected() {
        let formantsSaidYes = VowelCheck(isMatch: true, heard: "ɑ", matchingSeconds: 1)
        let result = VowelTranscript.decide(formants: formantsSaidYes, transcripts: ["Eee"], target: "ɑ")
        #expect(!result.isMatch)
    }

    @Test func noTranscriptLeavesItToTheFormants() {
        let formantsSaidYes = VowelCheck(isMatch: true, heard: "u", matchingSeconds: 1)
        #expect(VowelTranscript.decide(formants: formantsSaidYes, transcripts: [], target: "u").isMatch)
        #expect(!VowelTranscript.decide(formants: unsure, transcripts: ["hello"], target: "u").isMatch)
    }
}

@MainActor
struct VowelPracticeViewModelTests {
    private func makeViewModel(vowelMatches: Bool) -> (VowelPracticeViewModel, DummyRecordingService) {
        let content = InMemoryContentRepository()
        let recording = DummyRecordingService()
        let check = DummyVowelCheckService()
        check.answer = vowelMatches
        let vm = VowelPracticeViewModel(
            exerciseId: "sounds.vowel", recording: recording, vowelCheck: check,
            voice: DummySpeechSynthesisService(), progress: InMemoryProgressRepository(content: content),
            router: AppRouter(isOnboardingComplete: true)
        )
        return (vm, recording)
    }

    /// Starts a try, waits past the minimum length, then taps the mic again to end it.
    private func say(into vm: VowelPracticeViewModel) async {
        vm.didTapMicrophone()
        while vm.phase != .listening { await Task.yield() }
        try? await Task.sleep(for: .milliseconds(600))
        vm.didTapMicrophone()
        while vm.phase == .listening { await Task.yield() }
    }

    @Test func theWrongSoundKeepsThePlaneInPlace() async {
        let (vm, _) = makeViewModel(vowelMatches: false)
        vm.didTapStart()
        await say(into: vm)
        #expect(vm.goodTries == 0)
        #expect(vm.pathProgress == 0)
        #expect(vm.phase == .tryAgain)
    }

    @Test func theRightSoundMovesThePlane() async {
        let (vm, _) = makeViewModel(vowelMatches: true)
        vm.didTapStart()
        await say(into: vm)
        #expect(vm.goodTries == 1)
        #expect(vm.phase == .ready)
    }
}
