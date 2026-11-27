import SwiftUI
import UIKit    // UIImage(named:) to check whether the picture has been added yet

/// Space reserved for a picture that has not been made yet.
///
/// Shows the image called `imageName` from Assets once it exists; until then the space
/// stays empty, so the layout already matches Figma. To fill a slot, add an image set
/// with exactly that name to Assets.xcassets. No code change is needed.
struct ConversationImageSlot: View {
    let imageName: String?

    var body: some View {
        if let imageName, UIImage(named: imageName) != nil {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)
        } else {
            Color.clear
        }
    }
}

#Preview {
    ConversationImageSlot(imageName: "img_conversation_shopkeeper")
        .frame(width: 300, height: 300)
        .border(.gray)
}
