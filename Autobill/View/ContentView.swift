//
//  ContentView.swift
//  Autobill
//
//  Created by apple on 4/24/24.
//

import SwiftUI

struct ContentView: View {
    let gridItem = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @State var images: [UIImage] = [.sampleBill1, .sampleBill2, .sampleBill3, .sampleBill4, .sampleBill5]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: gridItem) {
                    ForEach(images.indices, id: \.self) { index in
                        NavigationLink(destination: ImageScrollView(presentIndex: index, images: $images)) {
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Auto bill")
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        CameraView(images: $images)
                            .navigationBarBackButtonHidden()
                    } label: {
                        Image(systemName: "camera")
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem {
                    NavigationLink {
                        EmptyView()
                    } label: {
                        Image(systemName: "photo.badge.plus")
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}
