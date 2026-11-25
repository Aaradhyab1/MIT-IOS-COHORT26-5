import SwiftUI

// Colours used by the onboarding screens (splash and child profile).

extension EchoColor {
    /// "mm/dd/yyyy" placeholder in an empty form field.
    static let fieldPlaceholder = Color(hex: 0x8A97A8)
    /// Hairline under a form field.
    static let fieldUnderline = Color(hex: 0xD6E3F2)
}

extension EchoColor {
    /// Light blue circle behind a level number or icon.
    static let levelBadge = Color(hex: 0xE6F1FF)
    /// Box holding "For example" in the level information overlay.
    static let exampleSurface = Color(hex: 0xE6F1FF, opacity: 0.8)
    /// Frosted panel of an onboarding overlay ("Choose a starting level", "The 4 levels").
    static let overlaySheet = Color(hex: 0xF6FAFF, opacity: 0.92)
    /// Close button, dropdown field and similar controls on an overlay panel.
    static let overlayControl = Color.white.opacity(0.6)
    /// Open dropdown list on an overlay panel.
    static let dropdownSurface = Color.white.opacity(0.7)
    /// Level overview on Choose path, and the cards in the level information overlay.
    static let overviewSurface = Color.white.opacity(0.5)
    static let infoCardSurface = Color.white.opacity(0.78)
    /// Hairlines between the four levels in the overview.
    static let gridDivider = Color(hex: 0x0C1E3C, opacity: 0.08)
}

extension EchoShadow {
    /// Onboarding overlay panels.
    static let overlaySheet = EchoShadow(color: Color(hex: 0x0C3373, opacity: 0.16), radius: 16, y: 12)
    /// The open dropdown list.
    static let dropdown = EchoShadow(color: Color(hex: 0x0D1F3D, opacity: 0.12), radius: 8, y: 10)
}

extension EchoColor {
    /// Quick Check: dots for questions not reached yet (the current one is `accent`).
    static let progressDot = Color(hex: 0xCFE2F7)
    /// Result reveal steps: reached, not reached yet, and the final ✓.
    static let stepReached = Color(hex: 0xBFE2FF)
    static let stepReachedText = Color(hex: 0x0088FF)
    static let stepPending = Color(hex: 0xF2F7FD)
    static let stepPendingText = Color(hex: 0x778AA8)
    static let stepDone = Color(hex: 0xE0F7E8)
    static let stepDoneText = Color(hex: 0x14A661)
    /// Line between result steps that hasn't filled yet.
    static let stepTrack = Color(hex: 0xDFE6EF)
    /// Inner panel of a card (the level box on the result screen).
    static let innerSurface = Color.white.opacity(0.66)
    /// Tile behind a level's icon.
    static let symbolTile = Color(hex: 0x0A7CFF, opacity: 0.12)
}

extension EchoShadow {
    /// Soft lift under tappable answer options, so they read as buttons.
    static let option = EchoShadow(color: Color(hex: 0x0C3373, opacity: 0.08), radius: 4, y: 2)
}

extension EchoColor {
    /// "How scoring works" sheet background and its row dividers.
    static let sheetSurface = Color(hex: 0xF8FBFF)
    static let sheetDivider = Color(hex: 0xDBE5F2)
}
