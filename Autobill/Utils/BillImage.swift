//
//  BillImage.swift
//  Autobill
//
//  Created by 김동용 on 5/31/24.
//

import SwiftData
import UIKit.UIImage

@Model
final class BillImage {
    @Attribute(.unique) private(set) var id = UUID()
    
    var imageData: Data
    var totalAmountText: String
    var date: String
    private(set) var createdDate = Date()
    
    var image: UIImage {
        return UIImage(data: imageData) ?? UIImage(systemName: "photo.artframe")!
    }
    
    init(image: UIImage, totalAmountText: String, date: String) {
        self.imageData = image.jpegData(compressionQuality: 1.0) ?? Data()
        self.totalAmountText = totalAmountText
        self.date = date
    }
}
