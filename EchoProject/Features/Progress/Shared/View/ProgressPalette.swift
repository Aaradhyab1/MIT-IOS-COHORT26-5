import SwiftUI

/// Colours from the Figma "Progress v2" frames.
enum ProgressPalette {
    static let textPrimary = rgb(0x1F1F21)
    static let textSecondary = rgb(0x6B6B73)
    static let blue = rgb(0x007AFF)
    static let green = rgb(0x1A996B)
    static let greenText = rgb(0x0E7A55)
    static let greenSoft = rgb(0xDBF5EB)
    static let blueSoft = rgb(0xE5F2FF)
    static let purple = rgb(0x7A5AF5)
    static let purpleSoft = rgb(0xF0E8FF)
    static let orange = rgb(0xE8800F)
    static let orangeSoft = rgb(0xFFEFE0)
    static let track = rgb(0xE9ECF2)
    static let hairline = rgb(0xEDEFF4)
    static let divider = rgb(0xE6E8EE)
    static let streakFill = rgb(0xFFF1DC)
    static let streakText = rgb(0xA85A00)
    static let dayUpcoming = rgb(0x1F1F21, 0.06)
    static let connectorIdle = rgb(0xDCE1EA)
    static let markerIdle = rgb(0xEEF0F5)
    static let card = Color.white
    static let cardShadow = rgb(0x1A3380, 0.08)
    static let glassShadow = rgb(0x1A4099, 0.10)
    static let glassStroke = Color.white.opacity(0.85)

    static let background = LinearGradient(
        colors: [rgb(0xF3F9FF), rgb(0xE6F2FD), rgb(0xD2E7F9)],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Per track

    static func tint(_ track: ProgressTrack) -> Color {
        track == .listening ? blue : green
    }

    /// Text on a tinted chip or caption needs a darker green to stay readable.
    static func tintText(_ track: ProgressTrack) -> Color {
        track == .listening ? blue : greenText
    }

    static func iconGradient(_ track: ProgressTrack) -> LinearGradient {
        let colors = track == .listening
            ? [rgb(0x2F8BFF), rgb(0x4F5BE8)]
            : [rgb(0x25B98C), rgb(0x0E8E9B)]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    // MARK: - Accents

    static func accent(_ accent: ProgressAccent) -> Color {
        switch accent {
        case .blue: blue
        case .green: green
        case .purple: purple
        case .orange: orange
        }
    }

    static func accentSoft(_ accent: ProgressAccent) -> Color {
        switch accent {
        case .blue: blueSoft
        case .green: greenSoft
        case .purple: purpleSoft
        case .orange: orangeSoft
        }
    }

    private static func rgb(_ hex: UInt32, _ opacity: Double = 1) -> Color {
        Color(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
