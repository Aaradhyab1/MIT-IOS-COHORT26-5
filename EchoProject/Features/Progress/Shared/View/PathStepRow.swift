import SwiftUI

/// One level on the path timeline: a marker, a connector to the next level, and its text.
struct PathStepRow: View {
    let step: ProgressPathStep
    let tint: Color
    let isLast: Bool

    @ScaledMetric(relativeTo: .headline) private var markerSize: CGFloat = 28

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                marker
                    .frame(width: markerSize, height: markerSize)
                if !isLast {
                    Capsule()
                        .fill(step.isDone ? tint : ProgressPalette.connectorIdle)
                        .frame(width: 2)
                        .frame(minHeight: 10, maxHeight: .infinity)
                        .padding(.vertical, 2)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(step.title)
                        .font(.headline)
                        .foregroundStyle(isUpcoming ? ProgressPalette.textSecondary : ProgressPalette.textPrimary)
                    Spacer(minLength: 8)
                    if !isCurrent {
                        Text(note)
                            .font(.footnote)
                            .foregroundStyle(ProgressPalette.textSecondary)
                    }
                }
                if let detail = step.detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(ProgressPalette.textSecondary)
                }
                if case .current(let completion, let note) = step.state {
                    HStack(spacing: 10) {
                        ProgressBar(value: completion, tint: tint, height: 6, track: ProgressPalette.connectorIdle.opacity(0.6))
                        Text(note)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(tint)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.top, 3)
            .padding(.bottom, isLast ? 0 : 14)
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Level \(step.number), \(step.title)")
        .accessibilityValue(accessibilityValue)
    }

    @ViewBuilder
    private var marker: some View {
        switch step.state {
        case .done:
            Circle()
                .fill(tint)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
        case .current:
            Circle()
                .fill(tint.opacity(0.12))
                .strokeBorder(tint, lineWidth: 2)
                .overlay {
                    Text(step.number, format: .number)
                        .font(.subheadline.bold())
                        .foregroundStyle(tint)
                }
        case .upcoming:
            Circle()
                .fill(ProgressPalette.markerIdle)
                .overlay {
                    Text(step.number, format: .number)
                        .font(.subheadline.bold())
                        .foregroundStyle(.tertiary)
                }
        }
    }

    private var isCurrent: Bool {
        if case .current = step.state { return true }
        return false
    }

    private var isUpcoming: Bool {
        if case .upcoming = step.state { return true }
        return false
    }

    private var note: String {
        switch step.state {
        case .done(let note), .current(_, let note), .upcoming(let note): note
        }
    }

    private var accessibilityValue: String {
        switch step.state {
        case .done(let note): "Complete, \(note)"
        case .current(let completion, _): "In progress, \(completion.formatted(.percent.precision(.fractionLength(0))))"
        case .upcoming(let note): note
        }
    }
}
