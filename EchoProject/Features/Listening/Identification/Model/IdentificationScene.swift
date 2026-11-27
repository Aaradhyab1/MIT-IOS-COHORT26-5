import CoreGraphics

/// Where each picture of an Identification exercise stands on the meadow.
///
/// Every position is in the 402 × 874 Figma frame (iPhone 16 Pro), measured from the
/// top-left corner. The View scales the whole meadow to fill the screen, so the
/// pictures stay on the grass on every iPhone size.
/// Figma: edit_cl › 08 · Level 3 — Instruments, 09 · Level 3 — Animals.
struct IdentificationScene {
    /// What a picture stands on: instruments sit on cream mats, animals cast a soft shadow.
    enum Ground {
        case mat(CGRect)
        case shadow(CGRect)
    }

    /// One picture on the meadow.
    struct Slot {
        /// Asset name of the picture. Nil until the art is drawn; the mat then shows the name.
        let art: String?
        let artFrame: CGRect
        let ground: Ground
        /// Centre of the name label on the "Meet the …" learning screen.
        let labelCenter: CGPoint

        /// A picture standing on a mat; the label sits just under the mat.
        init(art: String?, artFrame: CGRect, mat: CGRect) {
            self.art = art
            self.artFrame = artFrame
            self.ground = .mat(mat)
            self.labelCenter = CGPoint(x: mat.midX, y: mat.maxY + 20)
        }

        /// A picture standing straight on the grass with a soft shadow under its feet.
        init(art: String, artFrame: CGRect, shadow: CGRect, labelCenter: CGPoint) {
            self.art = art
            self.artFrame = artFrame
            self.ground = .shadow(shadow)
            self.labelCenter = labelCenter
        }
    }

    /// Size of the Figma frame all positions are measured in.
    static let canvasSize = CGSize(width: 402, height: 874)

    /// "instrument" in "Tap the instrument you heard."
    let noun: String
    /// Plays a "Meet the …" step first, where the child hears every sound once.
    var teachesSounds = false
    /// Keyed by the option id from the exercise item, e.g. "drums".
    let slots: [String: Slot]

    // MARK: - Scenes

    static func forExercise(_ exerciseId: String, optionIds: [String]) -> IdentificationScene {
        switch exerciseId {
        case "identification.instruments": return .instruments
        case "identification.animals": return .animals
        default: return .placeholder(optionIds: optionIds)
        }
    }

    /// The four mats, in reading order: top-left, top-right, bottom-left, bottom-right.
    private static let mats: [CGRect] = [
        CGRect(x: 38, y: 556, width: 140, height: 34),
        CGRect(x: 212, y: 556, width: 160, height: 34),
        CGRect(x: 40, y: 726, width: 140, height: 34),
        CGRect(x: 212, y: 728, width: 160, height: 34)
    ]

    /// Instruments: guitar and drums at the back, flute and harmonium at the front.
    static let instruments = IdentificationScene(
        noun: "instrument",
        teachesSounds: true,
        slots: [
            "guitar": Slot(art: "img_instrument_guitar",
                           artFrame: CGRect(x: 69, y: 424, width: 77, height: 155), mat: mats[0]),
            "drums": Slot(art: "img_instrument_drums",
                          artFrame: CGRect(x: 215, y: 445, width: 153, height: 133), mat: mats[1]),
            "flute": Slot(art: "img_instrument_flute",
                          artFrame: CGRect(x: 45, y: 697, width: 131, height: 47), mat: mats[2]),
            "harmonium": Slot(art: "img_instrument_harmonium",
                              artFrame: CGRect(x: 224, y: 669, width: 137, height: 80), mat: mats[3])
        ]
    )

    /// Animals: cow and goat at the back, lion and elephant at the front, standing on the grass.
    static let animals = IdentificationScene(
        noun: "animal",
        teachesSounds: true,
        slots: [
            "cow": Slot(art: "img_animal_cow",
                        artFrame: CGRect(x: 21.6, y: 417, width: 144.2, height: 146.8),
                        shadow: CGRect(x: 49.8, y: 554, width: 100.3, height: 10),
                        labelCenter: CGPoint(x: 100, y: 578)),
            "goat": Slot(art: "img_animal_goat",
                         artFrame: CGRect(x: 239.9, y: 447.3, width: 112, height: 142.3),
                         shadow: CGRect(x: 259.5, y: 574, width: 88.9, height: 10),
                         labelCenter: CGPoint(x: 304, y: 614)),
            "lion": Slot(art: "img_animal_lion",
                         artFrame: CGRect(x: 25, y: 572.6, width: 162, height: 174),
                         shadow: CGRect(x: 53.8, y: 722, width: 104.3, height: 10),
                         labelCenter: CGPoint(x: 106, y: 764)),
            "elephant": Slot(art: "img_animal_elephant",
                             artFrame: CGRect(x: 223, y: 625.5, width: 150, height: 139),
                             shadow: CGRect(x: 253, y: 742, width: 90.1, height: 10),
                             labelCenter: CGPoint(x: 298, y: 782))
        ]
    )

    /// Exercises whose art isn't drawn yet (Nature, Objects): the same four mats,
    /// each showing the option's name, so the game can still be played.
    static func placeholder(optionIds: [String]) -> IdentificationScene {
        var slots: [String: Slot] = [:]
        for (index, id) in optionIds.prefix(mats.count).enumerated() {
            let mat = mats[index]
            slots[id] = Slot(art: nil,
                             artFrame: CGRect(x: mat.minX, y: mat.minY - 110, width: mat.width, height: 130),
                             mat: mat)
        }
        return IdentificationScene(noun: "picture", slots: slots)
    }
}
