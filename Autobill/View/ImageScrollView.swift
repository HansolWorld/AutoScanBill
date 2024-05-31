//
//  ImageScrollView.swift
//  Autobill
//
//  Created by 김동용 on 5/31/24.
//

import SwiftUI

struct ImageScrollView: View {
    var presentIndex: Int
    @Binding var images: [UIImage]
    @State private var scrollIndex: Int
    
    init(presentIndex: Int, images: Binding<[UIImage]>) {
        self.presentIndex = presentIndex
        self._images = images
        self._scrollIndex = State(initialValue: presentIndex)
    }
    
    var body: some View {
        TabView(selection: $scrollIndex) {
            ForEach(images.indices, id: \.self) { index in
                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .clipped()
                    .padding(40)
                    .id(index)
            }
        }
        .tabViewStyle(.page)
        .toolbar {
            Image(systemName: "trash")
                .foregroundStyle(.white)
                .onTapGesture {
                    images.remove(at: scrollIndex)
                }
        }
        .onAppear {
            scrollIndex = presentIndex
        }
    }
}
