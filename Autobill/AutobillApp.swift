//
//  AutobillApp.swift
//  Autobill
//
//  Created by apple on 4/24/24.
//

import SwiftData
import SwiftUI

@main
struct AutobillApp: App {
    @Environment(\.dismiss) var dismiss
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .tint(.black)
        }
        .modelContainer(for: BillImage.self)
    }
}
