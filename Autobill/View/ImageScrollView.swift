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
    @State private var scrollIndex: Int
    @State private var date = ""
    @State private var totalCost = "0"
    
    @Query(sort: \BillImage.createdDate, order: .forward)
    private var billImages: [BillImage]
    @Binding var selectedBill: [BillImage]
    
    init(index: Int = 0, selectedBill: Binding<[BillImage]>) {
        self.scrollIndex = index
        self._selectedBill = selectedBill
    }
    
    var body: some View {
        TabView(selection: $scrollIndex) {
            ForEach(selectedBill.indices, id: \.self) { currentIndex in
                VStack(spacing: .zero) {
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
                                $0.id == selectedBill[currentIndex].id
                            }) else {
                                return
                            }
                            selectedBill[currentIndex].totalAmountText = totalCost
                            selectedBill[currentIndex].date = date
                            billImages[index].totalAmountText = totalCost
                            billImages[index].date = date
                            try? context.save()
                            
                            if selectedBill.count == 1 {
                                dismiss()
                            }
                        } label: {
                            Text("저장")
                        }
                    }
                    .background(.white)
                    .foregroundStyle(.black)                    
                    
                    Image(uiImage: selectedBill[currentIndex].image)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .clipped()
                        .padding(40)
                        .id(currentIndex)
                }
                .onAppear {
                    totalCost = selectedBill[currentIndex].totalAmountText
                    date = selectedBill[currentIndex].date
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
    
    private func formatNumber(input: String) -> String {
        let filtered = input.filter { "0123456789.".contains($0) }

        if let number = Double(filtered) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2 // 소수점 2자리까지 설정
            return formatter.string(from: NSNumber(value: number)) ?? input
        }
        
        return input

    }
}
