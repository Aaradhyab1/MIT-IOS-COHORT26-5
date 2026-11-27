import Testing
@testable import EchoProject

@MainActor
struct NarrationVoiceTests {
    private typealias Voice = SpeechStoryNarrationService.VoiceSettings
    private typealias Candidate = Voice.Candidate

    private func voice(_ name: String, _ language: String = "en-IN", _ quality: Voice.Quality) -> Candidate {
        let tier = quality == .premium ? "premium" : quality == .enhanced ? "enhanced" : "compact"
        return Candidate(identifier: "com.apple.voice.\(tier).\(language).\(name)", name: name, language: language, quality: quality)
    }

    @Test func ishaPremiumComesFirst() {
        let installed = [voice("Sangeeta", .enhanced), voice("Isha", .enhanced), voice("Isha", .premium), voice("Rishi", .premium)]
        #expect(Voice.choose(from: installed) == voice("Isha", .premium))
    }

    @Test func withoutPremiumIshaEnhancedIsUsed() {
        let installed = [voice("Sangeeta", .enhanced), voice("Isha", .enhanced), voice("Rishi", .premium)]
        #expect(Voice.choose(from: installed) == voice("Isha", .enhanced))
    }

    @Test func thenSangeetaEnhanced() {
        let installed = [voice("Isha", .standard), voice("Sangeeta", .enhanced), voice("Rishi", .premium)]
        #expect(Voice.choose(from: installed) == voice("Sangeeta", .enhanced))
    }

    @Test func thenTheBestOtherIndianEnglishVoice() {
        let installed = [voice("Isha", .standard), voice("Rishi", .enhanced), voice("Samantha", "en-US", .premium)]
        #expect(Voice.choose(from: installed) == voice("Rishi", .enhanced))
    }

    @Test func noIndianEnglishVoiceLeavesItToTheSystemDefault() {
        let installed = [voice("Samantha", "en-US", .premium), voice("Daniel", "en-GB", .enhanced)]
        #expect(Voice.choose(from: installed) == nil)
    }

    @Test func namesWithASuffixStillMatch() {
        let suffixed = Candidate(identifier: "com.apple.voice.premium.en-IN.Isha", name: "Isha (Premium)", language: "en-IN", quality: .premium)
        #expect(Voice.choose(from: [voice("Rishi", .premium), suffixed]) == suffixed)
    }

    @Test func storiesReadSlightlySlowerThanTheChosenSpeed() {
        #expect(Voice.kidsPace < 1)
        #expect(Voice.kidsPace > 0.85)
    }
}
