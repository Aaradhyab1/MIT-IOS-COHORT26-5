import SwiftUI

/// Colour tokens for app UI (text, controls, surfaces).
///
/// Values come from the Echo v2 screens in the FINAL-PROTOTYPE Figma file. Always use a
/// token instead of a literal colour so a palette change is a one-line edit.
///
/// Illustration colours are kept separately in `EchoColor.Paper` and should only be used
/// for artwork, never for UI chrome.
enum EchoColor {
    // MARK: Text

    /// Titles, headings and body copy.
    static let textPrimary = Color(hex: 0x0C1E3C)
    /// Section subtitles, card metadata and other supporting text.
    static let textSecondary = Color(hex: 0x63748B)
    /// Longer descriptive text placed on the hero card.
    static let textTertiary = Color(hex: 0x3D4D66)
    /// Text and icons placed on `accentFill`.
    static let textOnAccent = Color.white
    /// Eyebrow, detail text and icons on locked content.
    static let textLocked = Color(hex: 0x737882)
    /// Titles on locked content.
    static let textLockedStrong = Color(hex: 0x545963)

    // MARK: Accent

    /// Links, pills, badges, progress rings and the selected state.
    static let accent = Color(hex: 0x0A7CFF)
    /// Background of the primary action button.
    static let accentFill = Color(hex: 0x0A84FF)

    // MARK: Surfaces

    /// Screen background gradient, top to bottom. See `echoScreenBackground()`.
    static let backgroundTop = Color(hex: 0xF3F9FF)
    static let backgroundMiddle = Color(hex: 0xE6F2FD)
    static let backgroundBottom = Color(hex: 0xD2E7F9)
    /// Fill of the large hero card, and the placeholder shown while artwork is missing.
    static let heroSurface = Color(hex: 0xEAF3FE)
    /// Translucent fill of standard cards.
    static let cardSurface = Color.white.opacity(0.72)
    /// Fill of small capsules such as `EchoMetaPill`.
    static let pillSurface = Color.white.opacity(0.90)
    /// Fill of the floating level badge.
    static let badgeSurface = Color.white.opacity(0.88)
    /// 1 pt hairline around cards, giving them a lit edge.
    static let surfaceStroke = Color.white.opacity(0.95)
    /// Fill and border of locked content.
    static let lockedSurface = Color(hex: 0xEBEDF1)
    static let lockedStroke = Color(hex: 0xEFF2F7)
    /// Unfilled part of a progress ring.
    static let ringTrack = Color(hex: 0xCCDEF7)

    /// "Echo Paper" illustration palette from the v2 art direction.
    /// Flat cut-paper colours for artwork only; do not use for text or controls.
    enum Paper {
        static let blue = Color(hex: 0x3D7BFF)
        static let lightBlue = Color(hex: 0x8FB4FF)
        static let navy = Color(hex: 0x1B2A4A)
        static let sunshine = Color(hex: 0xFFC857)
        static let coral = Color(hex: 0xFF8E7A)
        static let mint = Color(hex: 0x7BC8A4)
        static let cream = Color(hex: 0xFFF4E4)
        /// Background the illustrations are composed on.
        static let sky = Color(hex: 0xEAF3FE)
    }
}

extension Color {
    /// Creates an sRGB colour from a 24-bit hex value, e.g. `Color(hex: 0x3D7BFF)`.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
