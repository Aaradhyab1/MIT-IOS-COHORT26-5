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

    /// The "How to play" demo for Match the following. Every pair plays the same three beats,
    /// so the rhythm stays even: the finger presses the fruit's dot, drags a line across to
    /// its colour's dot, then lets go. Pairs play in `matchingPairs` order.
    enum MatchingStep: Hashable {
        case waiting
        /// Finger presses the fruit's dot.
        case touch(pair: Int)
        /// Finger has dragged the line across to the colour's dot.
        case drag(pair: Int)
        /// Finger lifts off; the pair stays connected.
        case release(pair: Int)
        /// All pairs connected and checked.
        case completed

        var isCompleted: Bool { self == .completed }
        var hasStarted: Bool { self != .waiting }

        /// The pair being demonstrated, if any.
        var pair: Int? {
            switch self {
            case .touch(let pair), .drag(let pair), .release(let pair): pair
            case .waiting, .completed: nil
            }
        }

        var handSpot: MatchingHandSpot {
            switch self {
            case .waiting: .offscreen
            case .touch(let pair): .fruitDot(pair: pair)
            case .drag(let pair): .colorDot(pair: pair)
            case .release(let pair): .liftedFromColorDot(pair: pair)
            case .completed: .liftedFromColorDot(pair: ComprehensionTutorial.matchingPairs.count - 1)
            }
        }

        var showsHand: Bool {
            switch self {
            case .touch, .drag, .release: true
            case .waiting, .completed: false
            }
        }

        /// The finger is pressed down (slightly smaller) while touching and dragging.
        var handIsPressing: Bool {
            switch self {
            case .touch, .drag: true
            case .waiting, .release, .completed: false
            }
        }

        /// How much of each pair's line is drawn, 0...1, in `matchingPairs` order.
        func lineProgress(forPair index: Int) -> Double {
            switch self {
            case .waiting: 0
            case .completed: 1
            case .touch(let pair): index < pair ? 1 : 0
            case .drag(let pair), .release(let pair): index <= pair ? 1 : 0
            }
        }

        /// Cards with a blue outline and a filled dot: every connected pair, the fruit being
        /// pressed, and the colour once the line reaches it. Cleared on the checked frame.
        var activeItems: Set<String> {
            guard let current = pair else { return [] }
            var items: Set<String> = []
            for (index, matching) in ComprehensionTutorial.matchingPairs.enumerated() where index <= current {
                items.insert(matching.id)
                if lineProgress(forPair: index) >= 1 { items.insert(matching.colorId) }
            }
            return items
        }
    }

    enum MatchingHandSpot: Equatable {
        case offscreen
        case fruitDot(pair: Int)
        case colorDot(pair: Int)
        case liftedFromColorDot(pair: Int)
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

    /// The same timing for every pair: a smooth glide to the fruit, a short hold, one steady
    /// drag across, then the finger lifts and moves on.
    static let matchingTransitions: [Transition<MatchingStep>] = {
        var transitions: [Transition<MatchingStep>] = []
        for pair in matchingPairs.indices {
            transitions.append(Transition(step: .touch(pair: pair), delay: pair == 0 ? 0.8 : 0.15, duration: 0.6))
            transitions.append(Transition(step: .drag(pair: pair), delay: 0.25, duration: 0.9))
            transitions.append(Transition(step: .release(pair: pair), delay: 0.2, duration: 0.3, curve: .easeOut))
        }
        transitions.append(Transition(step: .completed, delay: 0.4, duration: 0.4, curve: .easeOut))
        return transitions
    }()

    /// Seconds between entering one matching step and entering the next: the previous
    /// animation finishes, then the hold before this one.
    static func matchingPause(before index: Int) -> TimeInterval {
        guard matchingTransitions.indices.contains(index) else { return 0 }
        let previousAnimation = index == 0 ? 0 : matchingTransitions[index - 1].duration
        return previousAnimation + matchingTransitions[index].delay
    }
}
