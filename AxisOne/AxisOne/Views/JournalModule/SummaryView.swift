//
//  SummaryView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 30.07.2025.
//

import SwiftUI

struct SummaryView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var date: Date
    
    var body: some View {
        NavigationStack {
            Text("")
                .navigationTitle("Отчет")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .tint(.secondary)
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
