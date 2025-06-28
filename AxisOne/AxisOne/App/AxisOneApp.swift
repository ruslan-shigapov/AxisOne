//
//  AxisOneApp.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 27.06.2025.
//

import SwiftUI

@main
struct AxisOneApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                     PersistenceController.shared.container.viewContext)
        }
    }
}
