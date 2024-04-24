//
//  ContentView.swift
//  Autobill
//
//  Created by apple on 4/24/24.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    @State var images: [UIImage] = []
    var body: some View {
        CameraView(images: $images)
    }
}

#Preview {
    ContentView()
}


struct CameraView: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let scanningBillVC = VNDocumentCameraViewController()
        scanningBillVC.delegate = context.coordinator
        
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
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            for pageNumber in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageNumber)
                
                self.parent.images.append(image)
            }
            
            controller.dismiss(animated: true)
        }
    }
}
