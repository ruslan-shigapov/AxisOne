//
//  SummaryView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 30.07.2025.
//

import SwiftUI

struct SummaryView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let date: Date
    
    var body: some View {
        NavigationStack {
            Text("")
                .navigationTitle("Отчет")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        NavBarImageButtonView(type: .cancel) {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
