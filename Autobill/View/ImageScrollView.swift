//
//  ImageScrollView.swift
//  Autobill
//
//  Created by 김동용 on 5/31/24.
//

import SwiftUI
import SwiftData

struct ImageScrollView: View {
    
    @Environment(\.modelContext) private var context
    @State private var scrollIndex: Int
    private var presentIndex: Int
    
    @Query(sort: \BillImage.createdDate, order: .forward)
    private var billImages: [BillImage]
    
    init(presentIndex: Int) {
        self.presentIndex = presentIndex
        self._scrollIndex = State(initialValue: presentIndex)
    }
    
    var body: some View {
        TabView(selection: $scrollIndex) {
            ForEach(billImages.indices, id: \.self) { index in
                VStack(spacing: .zero) {
//                    TextField(billImages[index].totalAmountText)
//                    TextEditor(text: .constant(billImages[index].totalAmountText))
                    Text("결제일 \(billImages[index].date)")
                    Text("\(billImages[index].totalAmountText) 원")
                    Image(uiImage: billImages[index].image)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .clipped()
                        .padding(40)
                        .id(index)
                }
            }
        }
        .tabViewStyle(.page)
        .toolbar {
            Image(systemName: "trash")
                .foregroundStyle(.white)
                .onTapGesture {
                    deleteBillImage(scrollIndex)
                }
        }
        .onAppear {
            scrollIndex = presentIndex
        }
    }
    
    func deleteBillImage(_ index: Int) {
        for image in billImages {
            if image.id == billImages[index].id {
                context.delete(billImages[index])
            }
        }
    }
}
