//
//  CameraView.swift
//  Autobill
//
//  Created by 김동용 on 5/30/24.
//

import SwiftUI
import SwiftData
import VisionKit

struct CameraView: UIViewControllerRepresentable {
    @Query(sort: \BillImage.createdDate, order: .forward)
    private var billImages: [BillImage]
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let scanningBillVC = VNDocumentCameraViewController()
        scanningBillVC.delegate = context.coordinator
        scanningBillVC.navigationController?.isNavigationBarHidden = true
        
        return scanningBillVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: CameraView
        
        init(_ cameraView: CameraView) {
            self.parent = cameraView
        }
        
        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            for pageNumber in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageNumber)
                TextScanner.shared.scanText(from: image)
                parent.addBillImage(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func addBillImage(_ image: UIImage) {
        let totalAmountText = TextScanner.shared.text
        let date = TextScanner.shared.date
        let newImage = BillImage(image: image, totalAmountText: totalAmountText, date: date)
        context.insert(newImage)
    }
}
