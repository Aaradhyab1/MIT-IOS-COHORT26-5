import SwiftUI

/// "Echo Paper" palette from PRECODING. Owner: Dev A.
/// TODO(Dev A, Wed 18 Nov): rename roles to match the Figma variable names.
enum EchoColor {
    static let primary = Color(hex: 0x3D7BFF)        // blue
    static let primaryLight = Color(hex: 0x8FB4FF)   // light blue
    static let ink = Color(hex: 0x1B2A4A)            // navy text
    static let sunshine = Color(hex: 0xFFC857)       // yellow
    static let coral = Color(hex: 0xFF8E7A)
    static let mint = Color(hex: 0x7BC8A4)           // green
    static let cream = Color(hex: 0xFFF4E4)
    static let background = Color(hex: 0xEAF3FE)     // app background
}

extension Color {
    /// `Color(hex: 0x3D7BFF)`
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
