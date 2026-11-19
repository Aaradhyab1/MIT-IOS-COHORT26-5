import SwiftUI

/// Full-screen illustrated backdrops used behind exercise screens.
///
/// Every Listening exercise and the Speaking Sounds, Words and Sentences screens share
/// the same pastel landscape. The Conversation role-play uses the ice cream shop.
enum EchoBackdrop {
    case landscape
    case iceCreamShop

    /// Asset catalog name. The images are exported from Figma (originals in the
    /// "Shared Background" and "Background / Ice Cream Shop" components).
    var imageName: String {
        switch self {
        case .landscape: "img_bg_landscape"
        case .iceCreamShop: "img_bg_ice_cream_shop"
        }
    }
}

extension View {
    /// The soft blue gradient behind Home, Progress, Profile and other non-exercise screens.
    func echoScreenBackground() -> some View {
        background { EchoGradientBackground().ignoresSafeArea() }
    }

    /// An illustrated backdrop for exercise screens, filling the whole screen.
    ///
    /// The image is scaled to fill and cropped at the screen edges. The screen gradient is
    /// drawn underneath, so the screen still looks correct if the image asset is missing.
    func echoExerciseBackground(_ backdrop: EchoBackdrop = .landscape) -> some View {
        background {
            EchoGradientBackground()
                .overlay {
                    Image(backdrop.imageName)
                        .resizable()
                        .scaledToFill()
                        .accessibilityHidden(true)
                }
                .clipped()
                .ignoresSafeArea()
        }
    }
}

/// Top-to-bottom gradient shared by both background modifiers.
private struct EchoGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [EchoColor.backgroundTop, EchoColor.backgroundMiddle, EchoColor.backgroundBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
