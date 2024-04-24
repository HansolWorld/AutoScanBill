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
        ScrollView {
            VStack(spacing: 20) {
                ForEach(images, id:\.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Image Gallery")
        .toolbar {
            NavigationLink {
                CameraView(images: $images)
            } label: {
                Image(systemName: "camera")
            }
        }
    }
}

#Preview {
    ContentView()
}


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
        @Environment(\.presentationMode) var presentationMode
        
        init(_ cameraView: CameraView) {
            self.parent = cameraView
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            for pageNumber in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: pageNumber)
                
                self.parent.images.append(image)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
//            controller.dismiss(animated: true, completion: nil)
        }
    }
}
