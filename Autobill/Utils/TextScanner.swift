//
//  TextScanner.swift
//  Autobill
//
//  Created by 김동용 on 5/31/24.
//

import UIKit.UIImage
import Vision

final class TextScanner {
    static let shared = TextScanner()
    
    private init() { }
    
    func scanText(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        let recognizedStrings = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
        
        // 추후 로컬 데이터 저장
        print(recognizedStrings)
    }
}
