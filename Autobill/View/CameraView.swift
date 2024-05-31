//
//  CameraView.swift
//  Autobill
//
//  Created by 김동용 on 5/30/24.
//

import SwiftUI
import VisionKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
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
                self.parent.images.append(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
