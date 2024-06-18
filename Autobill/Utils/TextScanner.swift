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
    var text: String = ""
    var date: String = ""
    private init() { }
    
    func scanText(from image: UIImage) {
        text = ""
        date = ""
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
        
        text = getTotalAmountText(from: recognizedStrings)
        date = getDate(from: recognizedStrings)
    }
    
    private func getTotalAmountText(from textArray: [String]) -> String {
        var frequencyDict: [String: Int] = [:]

        for string in textArray {
            frequencyDict[string, default: 0] += 1
        }

        let sortedArray = frequencyDict.sorted(by: { $0.value > $1.value })
        
        return sortedArray.first?.key ?? ""
    }
    
    private func getDate(from textArray: [String]) -> String {
        let datePattern = #"(\d{4}-\d{2}-\d{2})"#

        guard let regex = try? NSRegularExpression(pattern: datePattern) else {
            return ""
        }

        let dateStrings = textArray.compactMap { string -> String? in
            let range = NSRange(location: 0, length: string.utf16.count)
            if let match = regex.firstMatch(in: string, options: [], range: range) {
                // 매칭된 부분에서 첫 번째 캡처 그룹 (yyyy-MM-dd) 추출
                if let dateRange = Range(match.range(at: 1), in: string) {
                    return String(string[dateRange])
                }
            }
            return nil
        }
        
        return dateStrings.first ?? ""
    }
}
