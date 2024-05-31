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
    var image: UIImage
    private(set) var createdDate = Date()
    
    init(image: UIImage) {
        self.image = image
    }
}
