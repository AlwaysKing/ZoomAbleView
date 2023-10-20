//
//  ZoomAbleVIew.swift
//  SwiftUIByExample
//
//  Created by cnsinda on 10/20/23.
//

import SwiftUI

struct ZoomAbleView<V: View>: View {
    var max: CGFloat = 3.0
    var min: CGFloat = 0.5
    var content: V

    @State private var zoom = 1.0
    @State private var contentOffset: CGSize = CGSizeZero
    @State private var preContentOffset: CGSize = CGSizeZero
    @State private var panelHover: CGPoint = CGPoint.zero
    @State private var contentSize: CGSize = CGSizeZero
    @State private var panelSize: CGSize = CGSizeZero
    @State private var mouseWheelEvent: Any?

    init(@ViewBuilder content: () -> V) {
        self.content = content()
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
}
