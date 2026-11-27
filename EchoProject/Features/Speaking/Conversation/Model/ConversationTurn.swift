import Foundation

/// One thing the child can answer, e.g. "Chocolate".
/// `imageName` is the picture slot for this choice; the slot stays empty until the
/// picture is added to Assets under that name.
struct ConversationChoice: Identifiable, Hashable {
    let id: String
    let label: String
    let imageName: String?
}

/// One turn of the role-play: the shopkeeper asks a question with 2 or 3 choices,
/// and the child says one of them.
///
/// Built from an `ExerciseItem`: `text` is the question, `options` are the choices
/// and `image` is the picture slot for the shopkeeper.
struct ConversationTurn: Identifiable, Hashable {
    let id: String
    let question: String
    let choices: [ConversationChoice]
    /// Under the speech bubble, e.g. "Tell the shopkeeper what you would like."
    let prompt: String
    let imageName: String?
    /// How the shopkeeper confirms an answer; "{choice}" is replaced by it.
    let confirmationTemplate: String

    init(_ item: ExerciseItem) {
        id = item.id
        question = item.text ?? ""
        choices = (item.options ?? []).map { option in
            ConversationChoice(id: option.id, label: option.label, imageName: option.image)
        }
        prompt = item.prompt ?? "Tell the shopkeeper what you would like."
        imageName = item.image
        confirmationTemplate = item.hint ?? "{choice}, great choice!"
    }

    /// "Chocolate, yummy!"
    func confirmation(for choice: ConversationChoice) -> String {
        confirmationTemplate
            .replacingOccurrences(of: "{choice}", with: choice.label.lowercased())
            .capitalizingFirstLetter()
    }

    /// What the shopkeeper says when the answer was not one of the choices:
    /// "Sorry, you can only choose chocolate, vanilla or strawberry. Which one would you like?"
    var retryLine: String {
        "Sorry, you can only choose \(Self.listed(choices.map { $0.label.lowercased() })). Which one would you like?"
    }

    /// "a", "a or b", "a, b or c".
    static func listed(_ words: [String]) -> String {
        guard let last = words.last else { return "" }
        let rest = words.dropLast()
        return rest.isEmpty ? last : rest.joined(separator: ", ") + " or " + last
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).uppercased() + dropFirst()
    }
}
