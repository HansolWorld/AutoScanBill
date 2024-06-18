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
    @Query(sort: \BillImage.date, order: .forward)
    private var billImages: [BillImage]
    private let gridItem = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: gridItem, alignment: .leading, pinnedViews: .sectionHeaders) {
                    ForEach(groupedBillImages.keys.sorted(), id: \.self) { month in
                        Section(
                            header: Text(month)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.2))
                        ) {
                            ForEach(groupedBillImages[month]!.indices, id: \.self) { index in
                                NavigationLink(destination: ImageScrollView(presentIndex: index)) {
                                    Image(uiImage: groupedBillImages[month]![index].image)
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
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
    
    private var groupedBillImages: [String: [BillImage]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        
        let grouped = Dictionary(grouping: billImages) { (billImage) -> String in
            let dateComponents = billImage.date.components(separatedBy: "-")
            return "\(dateComponents[0])-\(dateComponents[1])"
        }
        
        return grouped
    }
}
