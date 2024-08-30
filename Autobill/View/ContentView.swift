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
                            header: MonthHeaderView(month)
                        ) {
                            if let bills = groupedBillImages[month] {
                                ForEach(bills.indices, id: \.self) { index in
                                    NavigationLink(destination: ImageScrollView(presentIndex: index)) {
                                        Image(uiImage: bills[index].image)
                                            .resizable()
                                            .scaledToFit()
                                    }
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
    
    private func MonthHeaderView(_ month: String) -> some View {
        HStack {
            Text(month)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.2))
            
            Spacer()
            
            NavigationLink {
                PaperView(
                    totalCost: "\(calculateTotalCost(groupedBillImages[month]!))",
                    month: Int(convertDateFormat(from: month) ?? "0") ?? 0,
                    imageList: groupedBillImages[month]!.map({ $0.image })
                )
            } label: {
                Image(systemName: "doc")
                    .foregroundStyle(.white)
            }
        }
    }
    
    func convertDateFormat(from originalDateString: String) -> String? {
        let originalDateFormatter = DateFormatter()
        originalDateFormatter.dateFormat = "yyyy-MM"
        
        let targetDateFormatter = DateFormatter()
        targetDateFormatter.dateFormat = "MM"
        
        guard let date = originalDateFormatter.date(from: originalDateString) else {
            return nil
        }
        
        let monthString = targetDateFormatter.string(from: date)
        
        return monthString
    }
    
    func calculateTotalCost(_ billList: [BillImage]) -> Int {
        return billList.compactMap { bill in
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
            if let number = numberFormatter.number(from: bill.totalAmountText) {
                return number.intValue
            } else {
                return nil
            }
        }
        .reduce(0, +)
    }
}
