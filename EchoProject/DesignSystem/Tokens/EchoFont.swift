import SwiftUI

/// "Echo v2" type scale: 34 / 28 / 22 / 20 / 17 / 15 / 13, SF Pro, 13 pt floor,
/// full sentences at 15 pt or larger. Owner: Dev A.
/// TODO(Dev A, Wed 18 Nov): check each weight against the Figma text styles.
enum EchoFont {
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .semibold)
    static let title3 = Font.system(size: 20, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let subhead = Font.system(size: 15, weight: .regular)
    static let caption = Font.system(size: 13, weight: .regular)     // never smaller
}
