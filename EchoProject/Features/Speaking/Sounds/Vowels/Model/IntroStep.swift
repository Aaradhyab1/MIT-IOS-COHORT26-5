import Foundation

/// One row on "How it works".
struct IntroStep: Identifiable, Hashable {
    /// The picture at the start of a row: an SF Symbol or an artwork asset.
    enum Icon: Hashable {
        case symbol(String)
        case image(String)
    }

    let id: Int
    let icon: Icon
    let title: String
}
