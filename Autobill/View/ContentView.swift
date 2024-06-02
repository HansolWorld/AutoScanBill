//
//  ContentView.swift
//  Autobill
//
//  Created by apple on 4/24/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    
    @Environment(\.modelContext) private var context
    @Query(sort: \BillImage.createdDate, order: .forward)
    private var billImages: [BillImage] 
    private let gridItem = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: gridItem) {
                    ForEach(billImages.indices, id: \.self) { index in
                        NavigationLink(destination: ImageScrollView(presentIndex: index)) {
                            Image(uiImage: billImages[index].image)
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
                        CameraView()
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
