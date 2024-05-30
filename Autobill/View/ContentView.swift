//
//  ContentView.swift
//  Autobill
//
//  Created by apple on 4/24/24.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    let gridItem = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @State var images: [UIImage] = [.bobcat,.bullElk,.bullElkSparring]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: gridItem) {
                    ForEach(images.indices, id: \.self) { index in
                        NavigationLink(destination: ImageScrollView(presentIndex: index, images: $images)) {
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Auto bill")
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        CameraView(images: $images)
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
}

import SwiftUI

struct ImageScrollView: View {
    var presentIndex: Int
    @Binding var images: [UIImage]
    @State private var scrollIndex: Int
    
    init(presentIndex: Int, images: Binding<[UIImage]>) {
        self.presentIndex = presentIndex
        self._images = images
        self._scrollIndex = State(initialValue: presentIndex)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            ScrollViewReader { scrollView in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(images.indices, id: \.self) { index in
                            GeometryReader { geometry in
                                Image(uiImage: images[index])
                                    .resizable()
                                    .frame(height: 450)
                                    .scaledToFill()
                                    .aspectRatio(contentMode: .fit)
                                    
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .clipped()
                                    .padding(.horizontal, 20)
                                    .id(index)
                                    .onChange(of: geometry.frame(in: .global).minX) {
                                        scrollIndex = index + 1
                                    }
                            }
                            .frame(width: UIScreen.main.bounds.width)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .onAppear {
                    scrollView.scrollTo(scrollIndex)
                }
            }
            PageControl(numberOfPages: images.count, currentPage: $scrollIndex)
        }
        .onAppear {
            scrollIndex = presentIndex
        }
    }
}


struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.currentPage = currentPage
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged
        )
        return control
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var control: PageControl
        
        init(_ control: PageControl) {
            self.control = control
        }
        
        @objc func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
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

#Preview {
    ContentView()
}
