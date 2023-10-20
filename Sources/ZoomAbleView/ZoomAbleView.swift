import SwiftUI

struct ZoomAbleView<V: View>: View {
    var max: CGFloat
    var min: CGFloat
    var content: V
    var showControl: Bool
    var autoHidden: Bool

    @Binding var zoom: CGFloat
    @Binding var contentOffset: CGSize
    @State private var preContentOffset: CGSize = CGSizeZero
    @State private var panelHover: CGPoint = CGPoint.zero
    @State private var contentSize: CGSize = CGSizeZero
    @State private var panelSize: CGSize = CGSizeZero
    @State private var mouseWheelEvent: Any? = nil
    @State private var controlHover: Bool = false

    init(zoom: Binding<CGFloat>, offset: Binding<CGSize>, max: CGFloat = 3.0, min: CGFloat = 0.5, showControl: Bool = false, autoHidden: Bool = true, @ViewBuilder content: () -> V) {
        self.max = max
        self.min = min
        self.content = content()
        self.showControl = showControl
        self.autoHidden = autoHidden
        self._zoom = zoom
        self._contentOffset = offset
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                content
                    .scaledToFit()
                    .background(Color.black)
                    .clipped()
                    .scaleEffect(zoom, anchor: .center)
                    .offset(x: contentOffset.width, y: contentOffset.height)
                    .overlay(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear(perform: {
                                    contentSize = geometry.size
                                })
                                .onChange(of: geometry.size) {
                                    contentSize = geometry.size
                                }
                        }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                contentOffset.width = preContentOffset.width + gesture.translation.width
                                contentOffset.height = preContentOffset.height + gesture.translation.height
                            }
                            .onEnded { gesture in
                                contentOffset.width = preContentOffset.width + gesture.translation.width
                                contentOffset.height = preContentOffset.height + gesture.translation.height
                                preContentOffset = contentOffset
                            }
                    )
                Spacer()
            }
            .overlay {
                if showControl == true {
                    VStack {
                        HStack {
                            Spacer()
                            VStack {
                                VStack {
                                    if !autoHidden || (autoHidden && controlHover) {
                                        ZoomAbleViewControlButton {
                                            reset()
                                        } content: {
                                            Image(systemName: "rectangle.on.rectangle.square").imageScale(.large)
                                        }

                                        ZoomAbleViewControlButton {
                                            zoomIn()
                                        } content: {
                                            Image(systemName: "plus.magnifyingglass").imageScale(.large)
                                        }

                                        ZoomAbleViewControlButton {
                                            zoomOut()
                                        } content: {
                                            Image(systemName: "minus.magnifyingglass").imageScale(.large)
                                        }
                                    }
                                }
                                .frame(width: 40, height: 120)
                                .onHover { controlHover = $0 }
                                .padding(10)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                }
            }
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear(perform: {
                            panelSize = geometry.size
                        })
                        .onChange(of: geometry.size) {
                            panelSize = geometry.size
                        }
                }
            )
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    panelHover = location
                case .ended:
                    break
                }
            }
            .onAppear {
                mouseWheelEvent = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                    scaleContent(event.scrollingDeltaY)
                    return event
                }
            }
            .onDisappear {
                if mouseWheelEvent != nil {
                    NSEvent.removeMonitor(mouseWheelEvent!)
                }
            }
        }
    }

    func scaleContent(_ delta: CGFloat) {
        let imageHover = panel2ContentPoint(panelHover)
        if imageHover.x < 0 || imageHover.x > contentSize.width * zoom || imageHover.y < 0 || imageHover.y > contentSize.height * zoom {
            return
        }

        var newZoom = zoom + delta / 100
        if newZoom < min {
            newZoom = min
        }
        if newZoom > max {
            newZoom = max
        }
        if newZoom == zoom {
            return
        }

        let hoverPer = CGSize(width: 0.5 - imageHover.x / (contentSize.width * zoom), height: 0.5 - imageHover.y / (contentSize.height * zoom))
        let offsetChange = CGSize(width: hoverPer.width * contentSize.width * (newZoom - zoom), height: hoverPer.height * contentSize.height * (newZoom - zoom))
        let newOffset = CGSize(width: contentOffset.width + offsetChange.width, height: contentOffset.height + offsetChange.height)

        withAnimation {
            contentOffset = newOffset
            zoom = newZoom
        }
        preContentOffset = contentOffset
    }

    func panel2ContentPoint(_ panelLocation: CGPoint) -> CGPoint {
        let panelCenter = CGPoint(x: panelSize.width / 2, y: panelSize.height / 2)
        let imageCenter = CGPoint(x: contentSize.width * zoom / 2, y: contentSize.height * zoom / 2)
        let convertedPoint = CGPoint(x: panelLocation.x - panelCenter.x + imageCenter.x - contentOffset.width,
                                     y: panelLocation.y - panelCenter.y + imageCenter.y - contentOffset.height)
        return convertedPoint
    }

    func reset() {
        withAnimation {
            zoom = 1.0
            contentOffset = CGSize(width: 0, height: 0)
        }
    }

    func zoomIn() {
        var newZoom = zoom + 0.2
        if newZoom > max {
            newZoom = max
        }
        if newZoom == zoom {
            return
        }
        withAnimation {
            zoom = newZoom
        }
    }

    func zoomOut() {
        var newZoom = zoom - 0.2
        if newZoom < min {
            newZoom = min
        }

        if newZoom == zoom {
            return
        }
        withAnimation {
            zoom = newZoom
        }
    }
}
