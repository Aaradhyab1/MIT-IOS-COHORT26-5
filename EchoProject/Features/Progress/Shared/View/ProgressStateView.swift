import SwiftUI

/// Shows a spinner while loading, a retry message on failure, and the screen once loaded.
struct ProgressStateView<Value: Hashable, Content: View>: View {
    let state: ProgressLoadState<Value>
    let retry: () async -> Void
    @ViewBuilder let content: (Value) -> Content

    var body: some View {
        switch state {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            ContentUnavailableView {
                Label("Progress unavailable", systemImage: "chart.line.downtrend.xyaxis")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") {
                    Task { await retry() }
                }
                .buttonStyle(.borderedProminent)
            }
        case .loaded(let value):
            content(value)
        }
    }
}
