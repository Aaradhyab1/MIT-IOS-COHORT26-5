import Foundation

/// The three states every Progress screen can be in.
enum ProgressLoadState<Value: Hashable>: Hashable {
    case loading
    case loaded(Value)
    case failed(String)

    var value: Value? {
        if case .loaded(let value) = self { return value }
        return nil
    }
}
