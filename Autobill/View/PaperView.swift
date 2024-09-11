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
    @State var totalCost: String
    let month: Int
    let imageList: [UIImage]
    
    @State private var scale = 1.0
    @GestureState private var magnification = 1.0

    var magnificationGesture: some Gesture {
      MagnifyGesture()
        .updating($magnification) { value, gestureState, transaction in
          gestureState = value.magnification
        }
        .onEnded { value in
          self.scale *= value.magnification
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack(spacing: 8) {
                    TextField("팀 이름", text: $teamName)
                    
                    TextField("이름", text: $name)
                    
                    TextField("커피는, 60계, 스텔라", text: $category)
                    
                    TextField("총 액", text: $totalCost)
                        .keyboardType(.numberPad)
                }
                .font(.subheadline)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.black, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                
                ScrollView([.horizontal, .vertical]) {
                    PrintPagePresetView(
                        pageIndex: pageIndex,
                        imageList: imageList,
                        teamName: teamName,
                        name: name,
                        category: category,
                        totalCost: formatNumber(Int(totalCost) ?? 0),
                        month: month,
                        preview: true
                    )
                    .scaleEffect(scale * magnification)
                    .highPriorityGesture(magnificationGesture)
                }
                .frame(height: UIScreen.main.bounds.height / 3 * 2)
                
                Spacer()
                
                HStack {
                    Image(systemName: "book.pages")
                    Text("Print")
                        .font(.body)
                }
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 32)
                .background(.ppOrange)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onTapGesture {
                    generatePDF(imageList.count)
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 20) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
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
                        .foregroundStyle(.black)
                        .padding(10)
                        .onTapGesture {
                            if pageIndex + 1 < convertToTotalPage(imageList.count) {
                                pageIndex += 1
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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
                rootView:
                    PrintPagePresetView(
                        pageIndex: index,
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
    
    func formatNumber(_ number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
