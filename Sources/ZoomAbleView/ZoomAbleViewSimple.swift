import SwiftUI

public struct ZoomAbleViewNoBinding<V: View>: View {
    var max: CGFloat
    var min: CGFloat
    var showControl: Bool
    var autoHidden: Bool

    @ViewBuilder var content: () -> V
    @State var zoom: CGFloat = 1.0
    @State var offset: CGSize = CGSize.zero

    public init(showControl: Bool = false, autoHidden: Bool = true, max: CGFloat = 3.0, min: CGFloat = 0.5, @ViewBuilder content: @escaping () -> V) {
        self.content = content
        self.showControl = showControl
        self.autoHidden = autoHidden
        self.max = max
        self.min = min
    }

    public var body: some View {
        ZoomAbleView(zoom: $zoom, offset: $offset, max: max, min: min, content: content)
    }
}
