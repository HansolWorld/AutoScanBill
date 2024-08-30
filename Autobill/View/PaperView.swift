//
//  PaperView.swift
//  Autobill
//
//  Created by 진태영 on 8/29/24.
//

import SwiftUI

import PDFKit

struct PaperView: View {
    @State private var pageIndex = 0
    @State private var pdfData: Data?
    @State private var teamName = ""
    @State private var name = ""
    @State private var category = "커피는"
    let totalCost: Int
    let month: Int
    
    let columns = [
        GridItem(.fixed(56), spacing: 0),
        GridItem(.fixed(56), spacing: 0),
        GridItem(.fixed(56), spacing: 0)
    ]
    let imageList: [UIImage]
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(spacing: 8) {
                TextField("팀 이름", text: $teamName)

                TextField("이름", text: $name)
                
                TextField("커피는, 60계, 스텔라", text: $category)
                
                Text(totalCost.formatted(.number))
            }
            .font(.subheadline)
            .border(.black)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding(10)
            .frame(maxWidth: .infinity)
            
            PrintPagePresetView(
                pageIndex: pageIndex,
                imageList: imageList,
                teamName: teamName,
                name: name,
                category: category,
                totalCost: totalCost,
                month: month,
                preview: true
            )
            
            Spacer()
            
            HStack {
                Image(systemName: "book.pages")
                Text("Print")
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding()
            }
            .onTapGesture {
                generatePDF(imageList.count)
            }
            .frame(maxWidth: .infinity)
            
            HStack(spacing: 20) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.white)
                    .padding(10)
                    .onTapGesture {
                        if pageIndex != 0 {
                            pageIndex -= 1
                        }
                    }
                
                
                Text("\(pageIndex + 1) / \(convertToTotalPage(imageList.count))")
                    .font(.caption)
                    .frame(height: 15)
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white)
                    .padding(10)
                    .onTapGesture {
                        if pageIndex + 1 < convertToTotalPage(imageList.count) {
                            pageIndex += 1
                        }
                    }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func convertToTotalPage(_ totalCount: Int) -> Int {
        let double = Double(totalCount) / 6
        let upperCount = ceil(double)
        
        return Int(upperCount)
    }
    
    func generatePDF(_ totalCount: Int) {
        var views: [UIView] = []
        let pageSize = CGSize(width: 595.2, height: 841.8) // A4 size in points
        
        for index in 0..<convertToTotalPage(totalCount) {
            let view = UIHostingController(
                rootView:             PrintPagePresetView(
                    pageIndex: pageIndex,
                    imageList: imageList,
                    teamName: teamName,
                    name: name,
                    category: category,
                    totalCost: totalCost,
                    month: month
                )
            ).view!
            view.frame = CGRect(origin: .zero, size: pageSize)
            views.append(view)
        }
        pdfData = PDFRenderer.createPDF(from: views, pageSize: pageSize)

        // Save PDF to Documents directory
        let filename = getDownloadsDirectory().appendingPathComponent("document.pdf")
        try? pdfData?.write(to: filename)
        
        // Share PDF
        if let pdfData {
            sharePDF(pdfData)
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func sharePDF(_ pdfData: Data) {
        let activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = scene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func getDownloadsDirectory() -> URL {
        // Get the path to the user's Downloads folder
        let fm = FileManager.default
        let urls = fm.urls(for: .downloadsDirectory, in: .userDomainMask)
        print("DEBUG - url: \(urls[0])")
        
        return urls[0]
    }
}
