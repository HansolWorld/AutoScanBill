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
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
        .modelContainer(for: BillImage.self)
    }
}
