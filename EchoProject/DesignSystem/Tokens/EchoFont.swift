import SwiftUI

/// The Echo v2 type scale.
///
/// Each case matches the Figma text style of the same name. The sizes and line heights are
/// identical to Apple's built-in text styles, so fonts are created from those styles and
/// automatically follow the user's Dynamic Type setting.
///
/// Accessibility rules from the design: nothing is set below `caption` (13 pt), and full
/// sentences use `supporting` (15 pt) or larger.
///
///     Text("Animal Sounds").echoFont(.display, .bold)
enum EchoTextStyle {
    /// 34 / 41 pt. Hero exercise titles.
    case display
    /// 28 / 34 pt. Screen titles and greetings.
    case title
    /// 22 / 28 pt. Large headings inside a screen.
    case heading
    /// 20 / 25 pt. Section titles.
    case subheading
    /// 17 / 22 pt. Body copy, buttons, card titles.
    case body
    /// 15 / 20 pt. Subtitles and descriptions. Smallest size for full sentences.
    case supporting
    /// 13 / 18 pt. Short labels and metadata. Smallest size used in the app.
    case caption

    /// The Apple text style with the same default size and line height.
    var textStyle: Font.TextStyle {
        switch self {
        case .display: .largeTitle
        case .title: .title
        case .heading: .title2
        case .subheading: .title3
        case .body: .body
        case .supporting: .subheadline
        case .caption: .footnote
        }
    }

    /// Point size at the default Dynamic Type setting.
    var size: CGFloat {
        switch self {
        case .display: 34
        case .title: 28
        case .heading: 22
        case .subheading: 20
        case .body: 17
        case .supporting: 15
        case .caption: 13
        }
    }

    /// Letter spacing in points. The design tightens text from 20 pt upward by 0.5 %.
    var tracking: CGFloat { size >= 20 ? -0.005 * size : 0 }
}

enum EchoFont {
    /// Returns the font for a style and weight.
    ///
    /// Prefer the `echoFont(_:_:)` view modifier, which also applies the style's tracking.
    /// Use this only where a `Font` value is required.
    static func font(_ style: EchoTextStyle, _ weight: Font.Weight = .regular) -> Font {
        .system(style.textStyle, weight: weight)
    }
}

extension View {
    /// Applies an Echo v2 text style: font, weight and letter spacing.
    func echoFont(_ style: EchoTextStyle, _ weight: Font.Weight = .regular) -> some View {
        font(EchoFont.font(style, weight)).tracking(style.tracking)
    }
}
