import Foundation

enum ComprehensionTutorial {
    enum OrderingStep: Int, Equatable {
        case waiting
        case pointToSeed
        case seedPlaced
        case pointToWater
        case waterPlaced
        case pointToFlower
        case completed

        var placedCardCount: Int {
            switch self {
            case .waiting, .pointToSeed: 0
            case .seedPlaced, .pointToWater: 1
            case .waterPlaced, .pointToFlower: 2
            case .completed: 3
            }
        }

        var handTarget: String? {
            switch self {
            case .pointToSeed, .seedPlaced: "seed"
            case .pointToWater, .waterPlaced: "water"
            case .pointToFlower: "flower"
            case .waiting, .completed: nil
            }
        }

        var isCompleted: Bool { self == .completed }
        var hasStarted: Bool { self != .waiting }
    }

    /// The frames of the Figma "Instruction animation – question 3 (match the following)" flow,
    /// Steps 30–41 and "checked · variant2". The hand drags a line from each fruit's dot to its
    /// colour's dot: banana → yellow, apple → red, grapes → purple.
    enum MatchingStep: Int, CaseIterable, Equatable {
        case waiting          // Step 30
        case touchBanana      // Step 31
        case dragBanana       // Step 32
        case reachYellow      // Step 33
        case releaseBanana    // Step 34
        case touchApple       // Step 35
        case reachRed         // Step 36
        case releaseApple     // Step 37
        case touchGrapes      // Step 38
        case dragGrapes       // Step 39
        case reachPurple      // Step 40
        case releaseGrapes    // Step 41
        case completed        // Step 9 · checked · variant2

        var isCompleted: Bool { self == .completed }
        var hasStarted: Bool { self != .waiting }

        /// Where the pointing hand is. It keeps moving while it fades, as in Figma's Smart Animate.
        var handSpot: MatchingHandSpot {
            switch self {
            case .waiting: .offscreen
            case .touchBanana: .bananaDot
            case .dragBanana: .bananaToYellow
            case .reachYellow, .releaseBanana: .yellowDot
            case .touchApple: .appleDot
            case .reachRed, .releaseApple: .redDot
            case .touchGrapes: .grapesTile
            case .dragGrapes: .grapesToPurple
            case .reachPurple: .purpleTile
            case .releaseGrapes, .completed: .redDot
            }
        }

        var showsHand: Bool {
            switch self {
            case .touchBanana, .dragBanana, .reachYellow,
                 .touchApple, .reachRed,
                 .touchGrapes, .dragGrapes, .reachPurple:
                true
            case .waiting, .releaseBanana, .releaseApple, .releaseGrapes, .completed:
                false
            }
        }

        /// How much of each pair's line is drawn, 0...1, in `matchingPairs` order.
        func lineProgress(forPair index: Int) -> Double {
            switch index {
            case 0: self == .dragBanana ? 0.5 : (rawValue >= MatchingStep.reachYellow.rawValue ? 1 : 0)
            case 1: rawValue >= MatchingStep.reachRed.rawValue ? 1 : 0
            case 2: rawValue >= MatchingStep.reachPurple.rawValue ? 1 : 0
            default: 0
            }
        }

        /// Cards with a blue outline and a filled dot. Cleared on the final checked frame.
        var activeItems: Set<String> {
            var items: Set<String> = []
            guard self != .completed else { return items }
            if rawValue >= MatchingStep.touchBanana.rawValue { items.insert("banana") }
            if rawValue >= MatchingStep.reachYellow.rawValue { items.insert("yellow") }
            if rawValue >= MatchingStep.touchApple.rawValue { items.insert("apple") }
            if rawValue >= MatchingStep.reachRed.rawValue { items.insert("red") }
            if rawValue >= MatchingStep.dragGrapes.rawValue { items.insert("grapes") }
            if rawValue >= MatchingStep.reachPurple.rawValue { items.insert("purple") }
            return items
        }
    }

    enum MatchingHandSpot: Equatable {
        case offscreen
        case bananaDot
        case bananaToYellow
        case yellowDot
        case appleDot
        case redDot
        case grapesTile
        case grapesToPurple
        case purpleTile
    }

    enum OrderingArtwork: String {
        case water
        case seed
        case flower
    }

    struct OrderingCard: Identifiable, Equatable {
        let id: String
        let title: String
        let artwork: OrderingArtwork
    }

    struct MatchingPair: Identifiable, Equatable {
        let id: String
        let fruit: String
        let fruitArtwork: String
        let colorId: String
    }

    struct MatchingColor: Identifiable, Equatable {
        let id: String
        let title: String
        let artwork: String
    }

    enum Curve: Equatable {
        case easeInOut
        case easeOut
    }

    /// One prototype connection: wait `delay` on the current frame (after its own animation
    /// has finished), then animate into `step` over `duration`.
    struct Transition<Step: Equatable> {
        let step: Step
        let delay: TimeInterval
        var duration: TimeInterval = ComprehensionTutorial.animationDuration
        var curve: Curve = .easeInOut
    }

    static let orderingTitle = "Put the steps in order"
    static let orderingSubtitle = "Show how a seed becomes a flower."
    static let matchingTitle = "Find the matching pairs"
    static let matchingSubtitle = "Match each fruit to its color."

    // Figma uses a 1.5 s opening wait, then 0.75 s delays and 0.48 s EaseInOut transitions.
    static let openingDelay: TimeInterval = 1.5
    static let frameDelay: TimeInterval = 0.75
    static let animationDuration: TimeInterval = 0.48

    /// Figma starts with water, seed, flower; the walkthrough moves them into story order.
    static let orderingCards = [
        OrderingCard(id: "water", title: "Water the seed.", artwork: .water),
        OrderingCard(id: "seed", title: "Plant a seed.", artwork: .seed),
        OrderingCard(id: "flower", title: "Watch it bloom.", artwork: .flower)
    ]

    static let matchingPairs = [
        MatchingPair(id: "banana", fruit: "Banana", fruitArtwork: "img_tutorial-banana", colorId: "yellow"),
        MatchingPair(id: "apple", fruit: "Apple", fruitArtwork: "img_tutorial-apple", colorId: "red"),
        MatchingPair(id: "grapes", fruit: "Grapes", fruitArtwork: "img_tutorial-grapes", colorId: "purple")
    ]

    /// The right column order in Figma is intentionally different from the answer order.
    static let matchingColors = [
        MatchingColor(id: "red", title: "Red", artwork: "img_tutorial-red"),
        MatchingColor(id: "yellow", title: "Yellow", artwork: "img_tutorial-yellow"),
        MatchingColor(id: "purple", title: "Purple", artwork: "img_tutorial-purple")
    ]

    static let orderingTransitions: [Transition<OrderingStep>] = [
        Transition(step: .pointToSeed, delay: openingDelay),
        Transition(step: .seedPlaced, delay: frameDelay),
        Transition(step: .pointToWater, delay: frameDelay),
        Transition(step: .waterPlaced, delay: frameDelay),
        Transition(step: .pointToFlower, delay: frameDelay),
        Transition(step: .completed, delay: frameDelay)
    ]

    /// Timings copied from the Figma prototype connections between Steps 30–41 and the checked frame.
    static let matchingTransitions: [Transition<MatchingStep>] = [
        Transition(step: .touchBanana, delay: 1.5, duration: 0.48),
        Transition(step: .dragBanana, delay: 0.75, duration: 0.48),
        Transition(step: .reachYellow, delay: 0.15, duration: 0.48),
        Transition(step: .releaseBanana, delay: 0.75, duration: 0.48),
        Transition(step: .touchApple, delay: 0.75, duration: 0.48),
        Transition(step: .reachRed, delay: 0.75, duration: 0.48),
        Transition(step: .releaseApple, delay: 0.75, duration: 0.48),
        Transition(step: .touchGrapes, delay: 1.2, duration: 0.35),
        Transition(step: .dragGrapes, delay: 0.75, duration: 0.35),
        Transition(step: .reachPurple, delay: 0.75, duration: 0.35),
        Transition(step: .releaseGrapes, delay: 0.75, duration: 0.35),
        Transition(step: .completed, delay: 1.2, duration: 0.25, curve: .easeOut)
    ]

    /// Seconds between entering one matching frame and entering the next: the previous
    /// animation has to finish before Figma's "after delay" timer starts.
    static func matchingPause(before index: Int) -> TimeInterval {
        guard matchingTransitions.indices.contains(index) else { return 0 }
        let previousAnimation = index == 0 ? 0 : matchingTransitions[index - 1].duration
        return previousAnimation + matchingTransitions[index].delay
    }
}
