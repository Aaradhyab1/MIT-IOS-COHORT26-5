import SwiftUI

/// A list of everyday speaking wins, separated by inset hairlines.
struct SpeechMomentsCard: View {
    let moments: [ProgressSpeechMoment]

    var body: some View {
        ProgressPlainCard(padding: 0) {
            VStack(spacing: 0) {
                ForEach(moments) { moment in
                    if moment.id != moments.first?.id {
                        Rectangle()
                            .fill(ProgressPalette.divider)
                            .frame(height: 1)
                            .padding(.leading, 68)
                    }
                    SpeechMomentRow(moment: moment)
                        .padding(.horizontal, 16)
                }
            }
        }
    }
}
