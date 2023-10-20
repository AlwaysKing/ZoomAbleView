import SwiftUI

struct ContentView: View {
    @State var zoom: CGFloat = 1.0
    @State var offset: CGSize = CGSize.zero

    var body: some View {
        VStack {
            ZoomAbleViewNoBinding {
                Image(systemName: "trash")
                    .resizable()
            }

            Spacer()

            HStack {
                Button("reset") {
                    withAnimation {
                        zoom = 1.0
                        offset = CGSize(width: 0, height: 0)
                    }
                }

                Button("zoomIn") {
                    withAnimation {
                        zoom = zoom + 0.2
                    }
                }

                Button("zoomOut") {
                    withAnimation {
                        zoom -= 0.2
                    }
                }
                Spacer()
            }.frame(height: 100)
                .background(.green)
        }
    }
}

#Preview {
    ContentView()
}
