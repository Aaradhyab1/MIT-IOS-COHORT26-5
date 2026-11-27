import SwiftUI

/// Bottom sheet for one word: the word, how to say it ("MOR-ning") and a button
/// to hear it slowly. Figma: "Paragraph Recitation / Pronunciation Sheet" (402 × 266)
/// and "speech · paragraph · word · helper · ready / normal · playback".
struct PronunciationSheet: View {
    let word: ReadingWord
    let isPlaying: Bool
    let onHear: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: EchoSpacing.l) {
            HStack {
                Text(word.spoken.isEmpty ? word.text : word.spoken)
                    .echoFont(.heading, .bold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                EchoIconButton(systemImage: "xmark", accessibilityLabel: "Close", action: onClose)
            }

            Text(word.syllables)
                .echoFont(.body)
                .foregroundStyle(isPlaying ? SentencesStyle.hint : EchoColor.textPrimary)
                .accessibilityLabel("Say it like: \(word.syllables)")

            Button("Hear pronunciation", action: onHear)
                .buttonStyle(.echoPrimary)
                .disabled(isPlaying)
                .opacity(isPlaying ? 0.45 : 1)
                .padding(.horizontal, 20)
        }
        .padding(.horizontal, EchoSpacing.screenHorizontal)
        .padding(.top, 28)
        .frame(maxHeight: .infinity, alignment: .top)
        .presentationDetents([.height(266)])
        .presentationDragIndicator(.visible)
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
    }
}
