//
//  ImageScrollView.swift
//  Autobill
//
//  Created by 김동용 on 5/31/24.
//

import SwiftUI
import SwiftData

struct ImageScrollView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let selectedIndex: Int
    @State private var scrollIndex = 0
    @State private var date = ""
    @State private var totalCost = "0"
    
    @Query(sort: \BillImage.createdDate, order: .forward)
    private var billImages: [BillImage]
    @Binding var selectedBill: [BillImage]
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("결제일:")
                        
                        TextField("2024-00-00", text: $date)
                            .keyboardType(.numbersAndPunctuation)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack {
                        Text("금액:")
                        
                        TextField("총 액", text: $totalCost)
                            .keyboardType(.numberPad)
                            .onChange(of: totalCost) { oldValue, newValue in
                                totalCost = formatNumber(input: newValue)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(alignment: .leading)
                
                Spacer()
                
                Button {
                    guard let index = billImages.firstIndex(where: {
                        $0.id == selectedBill[scrollIndex].id
                    }) else {
                        return
                    }
                    selectedBill[scrollIndex].totalAmountText = totalCost
                    selectedBill[scrollIndex].date = date
                    billImages[index].totalAmountText = totalCost
                    billImages[index].date = date
                    try? context.save()
                    
                    if selectedBill.count == 1 {
                        dismiss()
                    }
                } label: {
                    Text("수정")
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .foregroundStyle(.black)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.black, lineWidth: 1)
            )
            .padding(.horizontal, 20)
            
            TabView(selection: $scrollIndex) {
                ForEach(Array(selectedBill.enumerated()), id: \.1.id) { index, bill in
                    VStack(spacing: .zero) {
                        Image(uiImage: bill.image)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .clipped()
                            .padding(40)
                    }
                    .tag(index)
                    .padding(.horizontal, 20)
                    .onAppear {
                        totalCost = bill.totalAmountText
                        date = bill.date
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
        .background(.white)
        .toolbar {
            Image(systemName: "trash")
                .foregroundStyle(.black)
                .onTapGesture {
                    guard let index = billImages.firstIndex(where: { $0.id == selectedBill[scrollIndex].id }) else {
                        return
                    }
                    deleteBillImage(index)
                }
        }
        .onAppear {
            scrollIndex = selectedIndex
            UIApplication.shared.hideKeyboard()
            UIPageControl.appearance().currentPageIndicatorTintColor = .ppOrange
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        }
    }
    
    func deleteBillImage(_ index: Int) {
        context.delete(billImages[index])
    }
    
    private func formatNumber(input: String) -> String {
        let filtered = input.filter { "0123456789.".contains($0) }
        
        if let number = Double(filtered) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: number)) ?? input
        }
        
        return input
    }
}
