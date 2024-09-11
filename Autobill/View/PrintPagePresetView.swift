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
    let totalCost: String
    let month: Int
    var preview = false
    
    private var itemRange: Range<Int> {
        let start = pageIndex * 6
        let end = min(start + 6, imageList.count)
        
        return start..<end
    }

    // width 198.4
        // height 279.744
    let printColumns = [
        GridItem(.fixed(198.4), spacing: 0),
        GridItem(.fixed(198.4), spacing: 0),
        GridItem(.fixed(198.4), spacing: 0)
    ]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if preview {
                Rectangle()
                    .fill(.clear)
                    .strokeBorder(.gray, style: .init(lineWidth: 1, dash: [20]))
                    .frame(width: 595.2, height: 841.8, alignment: .top)
            }

            VStack(alignment: .trailing, spacing: 20) {
                Text("\(teamName) \(name), \(category), \(month)월, \(totalCost)원")
                    .font(.subheadline)
                    .padding(.trailing, 10)
                    .frame(height: 30)
                LazyVGrid(columns: printColumns, spacing: 1) {
                    ForEach(itemRange, id: \.self) { index in
                        Image(uiImage: imageList[index])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 198.4, height: 198.4 * 1.8)
                            .overlay(
                                Rectangle()
                                    .strokeBorder(.black, lineWidth: 1)
                            )
                    }
                }
            }
            .frame(width: 595.2, height: 841.8, alignment: .top)
        }
        .frame(width: preview ? 1000 : 595.2, height: preview ? 1000 : 841.8, alignment: .top)
        //        .frame(width: preview ? nil : 595.2, height: preview ? nil : 841.8, alignment: .top) // A4 size
        .foregroundStyle(.black)
        .background(.white)
    }
}
