import SwiftUI

/// Compact 160 pt card for an exercise in a horizontal carousel,
/// e.g. "Practise what you've learned" on Home.
///
///     EchoExerciseCard(title: "Hide & Seek", meta: "Level 1 · 4 min",
///                      imageName: "img_hide_and_seek", action: { viewModel.open(exercise) })
struct EchoExerciseCard: View {
    let title: String
    /// One short line of metadata, e.g. "Level 1 · 4 min".
    let meta: String
    /// Asset catalog name of the thumbnail.
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: EchoSpacing.s) {
                EchoArtwork(imageName: imageName, cornerRadius: EchoRadius.thumbnailSmall)
                    .frame(height: 104)
                Text(title)
                    .echoFont(.supporting, .semibold)
                    .foregroundStyle(EchoColor.textPrimary)
                    .lineLimit(1)
                Text(meta)
                    .echoFont(.caption)
                    .foregroundStyle(EchoColor.textSecondary)
                    .lineLimit(1)
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 12, trailing: 10))
            .frame(width: 160, alignment: .leading)
            .echoCard()
        }
        .buttonStyle(.plain)
    }
}

/// Greyed-out card describing content the child has not unlocked yet,
/// with a lock icon and the rule for unlocking it. Not tappable.
///
///     EchoLockedCard(eyebrow: "Up next · Level 4", title: "Understand sounds",
///                    detail: "Play 6 more games to unlock.", imageName: "level_4")
struct EchoLockedCard: View {
    /// Short label above the title. Displayed in capitals.
    let eyebrow: String
    let title: String
    /// What the child needs to do to unlock the content.
    let detail: String
    /// Asset catalog name of the thumbnail. Shown in greyscale.
    let imageName: String

    var body: some View {
        HStack(spacing: 14) {
            EchoArtwork(imageName: imageName, cornerRadius: EchoRadius.thumbnail)
                .frame(width: 72, height: 72)
                .saturation(0)
            VStack(alignment: .leading, spacing: EchoSpacing.xs) {
                Text(eyebrow.uppercased())
                    .echoFont(.caption, .semibold)
                    .foregroundStyle(EchoColor.textLocked)
                Text(title)
                    .echoFont(.body, .semibold)
                    .foregroundStyle(EchoColor.textLockedStrong)
                Text(detail)
                    .echoFont(.supporting)
                    .foregroundStyle(EchoColor.textLocked)
            }
            Spacer(minLength: 0)
        }
        .padding(EchoSpacing.m)
        .padding(.trailing, 32) // Keeps text clear of the lock icon.
        .frame(maxWidth: .infinity)
        .background(EchoColor.lockedSurface, in: .rect(cornerRadius: EchoRadius.cardLarge))
        .overlay(alignment: .topTrailing) {
            Image(systemName: "lock.fill")
                .echoFont(.body, .semibold)
                .foregroundStyle(EchoColor.textLocked)
                .padding(EchoSpacing.l)
        }
        .overlay(
            RoundedRectangle(cornerRadius: EchoRadius.cardLarge)
                .stroke(EchoColor.lockedStroke, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityValue("Locked")
    }
}

/// Round category button with a progress ring, label and status line,
/// e.g. "Animals · 4 of 10" in a level's category row.
struct EchoCategoryTile: View {
    let title: String
    /// Status shown under the title, e.g. "4 of 10" or "New".
    let detail: String
    /// Asset catalog name of the round artwork.
    let imageName: String
    /// Completion from 0 to 1. The blue arc is hidden at 0.
    var progress: Double = 0
    /// Highlights the title in blue for the category the child is working on.
    var isCurrent = false
    let action: () -> Void

    private static let ringDiameter: CGFloat = 84
    private static let artDiameter: CGFloat = 68
    private static let ringWidth: CGFloat = 4

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(EchoColor.ringTrack, lineWidth: Self.ringWidth)
                    if progress > 0 {
                        Circle()
                            .trim(from: 0, to: min(progress, 1))
                            .stroke(EchoColor.accent, style: StrokeStyle(lineWidth: Self.ringWidth, lineCap: .round))
                            .rotationEffect(.degrees(-90)) // Start the arc at 12 o'clock.
                    }
                    EchoArtwork(imageName: imageName, cornerRadius: Self.artDiameter / 2)
                        .frame(width: Self.artDiameter, height: Self.artDiameter)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
                .frame(width: Self.ringDiameter, height: Self.ringDiameter)
                Text(title)
                    .echoFont(.supporting, .semibold)
                    .foregroundStyle(isCurrent ? EchoColor.accent : EchoColor.textPrimary)
                Text(detail)
                    .echoFont(.caption)
                    .foregroundStyle(EchoColor.textSecondary)
            }
            .frame(width: Self.ringDiameter)
        }
        .buttonStyle(.plain)
    }
}

/// Asset image cropped to a rounded rectangle.
/// While the asset is missing, a soft blue placeholder fills the same space,
/// so layouts can be built before artwork is exported.
struct EchoArtwork: View {
    let imageName: String
    let cornerRadius: CGFloat

    var body: some View {
        Rectangle()
            .fill(EchoColor.heroSurface)
            .overlay {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .accessibilityHidden(true)
    }
}
