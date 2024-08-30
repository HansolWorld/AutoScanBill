//
//  PrintPagePresetView.swift
//  Autobill
//
//  Created by 진태영 on 8/29/24.
//

import SwiftUI

struct PrintPagePresetView: View {
    let pageIndex: Int
    let imageList: [UIImage]
    let teamName: String
    let name: String
    let category: String
    let totalCost: Int
    let month: Int
    var preview = false
    
    private var itemRange: Range<Int> {
        let start = pageIndex * 6
        let end = min(start + 6, imageList.count)
        
        return start..<end
    }

    // width 198.4
        // height 279.744
    let previewColumns = [
        GridItem(.fixed(56), spacing: 0),
        GridItem(.fixed(56), spacing: 0),
        GridItem(.fixed(56), spacing: 0)
    ]
    
    let printColumns = [
        GridItem(.fixed(198.4), spacing: 0),
        GridItem(.fixed(198.4), spacing: 0),
        GridItem(.fixed(198.4), spacing: 0)
    ]

    var body: some View {
        VStack(alignment: .trailing, spacing: 20) {
            Text("\(teamName) \(name), \(category), \(month)월, \(totalCost)원")
                .font(.subheadline)
                .padding(.trailing, 10)
                .frame(height: 30)
            
            LazyVGrid(columns: preview ? previewColumns : printColumns, spacing: 1) {
                ForEach(itemRange, id: \.self) { index in
                    Image(uiImage: imageList[index])
                        .resizable()
                        .scaledToFit()
                        .frame(height: preview ? 105 : 279.744)
                        .overlay(
                            Rectangle()
                                .strokeBorder(.white, lineWidth: 1)
                        )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(width: preview ? nil : 595.2, height: preview ? nil : 841.8, alignment: .top) // A4 size
        .foregroundStyle(.black)
        .background(.white)
    }
}
