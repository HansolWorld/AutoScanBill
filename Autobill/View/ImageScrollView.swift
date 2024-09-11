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
    @State private var totalCost = ""
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
                    HStack {
                        VStack(alignment: .leading) {
                            Text("결제일 \(billImages[index].date)")
                            HStack {
                                Text("금액:")
                                
                                TextField("총 액", text: $totalCost)
                                    .keyboardType(.numberPad)
                            }
                        }
                        .frame(alignment: .leading)
                        
                        Spacer()
                        
                        Button(action: {
                            billImages[index].totalAmountText = totalCost
                            try? context.save()
                            
                        }, label: {
                            Text("SAVE")
                        })
                    }
                    .frame(maxWidth: .infinity)
                    
                    
                    Image(uiImage: billImages[index].image)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .clipped()
                        .padding(40)
                        .id(index)
                }
                .onAppear {
                    totalCost = billImages[index].totalAmountText
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
            UIApplication.shared.hideKeyboard()
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
