//
//  ContentView.swift
//  ZoomAbleImageView
//
//  Created by cnsinda on 10/20/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ZoomAbleView {
                Image(systemName: "trash")
                    .resizable()
            }

            Spacer()
            HStack {
                Spacer()
            }.frame(height: 100)
                .background(.green)
        }
    }
}

#Preview {
    ContentView()
}
