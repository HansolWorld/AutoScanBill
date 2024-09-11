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
    @State private var selectedImageList: [BillImage] = []
    @State private var isSelectMode = false
    @State private var navigateToDetail = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(Array(selectedImageList.enumerated()), id: \.1.id) { index, bill in
                            Image(uiImage: bill.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .onTapGesture {
                                    if isSelectMode {
                                        selectedImageList.removeAll(where: { $0.id == bill.id })
                                    } else {
                                        navigateToDetail = true
                                    }
                                }
                                .navigationDestination(isPresented: $navigateToDetail) {
                                    ImageScrollView(presentIndex: index)
                                }
                        }
                    }
                }
                
                if !selectedImageList.isEmpty {
                    NavigationLink {
                        PaperView(
                            totalCost: "\(calculateTotalCost(selectedImageList))",
                            month: Calendar.current.component(.month, from: Date()),
                            imageList: selectedImageList.map({ $0.image })
                        )
                    } label: {
                        Text("스캔하러가기")
                            .padding(.vertical, 12)
                            .padding(.horizontal, 32)
                            .background(.green)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                
                ScrollView {
                    LazyVGrid(columns: gridItem, alignment: .leading, pinnedViews: .sectionHeaders) {
                        ForEach(groupedBillImages.keys.sorted(), id: \.self) { month in
                            Section(
                                header: MonthHeaderView(month)
                            ) {
                                if let bills = groupedBillImages[month] {
                                    ForEach(Array(bills.enumerated()), id: \.1.id) { index, bill in
                                        Image(uiImage: bill.image)
                                            .resizable()
                                            .scaledToFit()
                                            .onTapGesture {
                                                if isSelectMode {
                                                    selectedImageList.append(bill)
                                                } else {
                                                    navigateToDetail = true
                                                }
                                            }
                                            .navigationDestination(isPresented: $navigateToDetail) {
                                                let index = billImages.firstIndex(where: { $0.id == bill.id })
                                                ImageScrollView(presentIndex: index ?? 0)
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
                    ToolbarItem {
                        Image(systemName: isSelectMode ? "checkmark.circle" : "checkmark.circle.fill")
                            .foregroundStyle(.white)
                            .onTapGesture {
                                isSelectMode.toggle()
                            }
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
    
    @ViewBuilder
    private func MonthHeaderView(_ month: String) -> some View {
        Text(month)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.2))
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
