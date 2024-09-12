//
//  PDFRenderer.swift
//  Autobill
//
//  Created by 진태영 on 8/29/24.
//

import UIKit

class PDFRenderer {
    static func createPDF(from views: [UIView], pageSize: CGSize) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        
        let data = pdfRenderer.pdfData { context in
            for view in views {
                context.beginPage()
                view.drawHierarchy(in: CGRect(origin: .zero, size: pageSize), afterScreenUpdates: true)
            }
        }
        
        return data
    }
}
