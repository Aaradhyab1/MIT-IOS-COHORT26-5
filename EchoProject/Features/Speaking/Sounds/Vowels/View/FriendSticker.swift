import SwiftUI

/// Round sticker of a friend met today, on the last screen.
struct FriendSticker: View {
    let image: String

    var body: some View {
        EchoAssetImage(name: image)
            .padding(EchoSpacing.s)
            .frame(width: 92, height: 92)
            .background(EchoColor.Paper.cream, in: Circle())
            .overlay { Circle().strokeBorder(.white, lineWidth: 4) }
            .echoShadow(.card)
    }
}
