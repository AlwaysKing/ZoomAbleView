import SwiftUI

struct ZoomAbleViewControlButton<V: View>: View {
    var content: V
    var action: () -> Void
    @State private var hover: Bool = false

    init(action: @escaping () -> Void, @ViewBuilder content: () -> V) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action, label: {
            content.padding(6)
                .onHover { hover = $0 }
                .background(hover ? .black.opacity(0.5) : .clear)
                .cornerRadius(6)
        })
        .buttonStyle(.plain)
    }
}
