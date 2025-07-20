//
//  HistoryView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct HistoryView: View {
    
    @FetchRequest(
        entity: Reflection.entity(),
        sortDescriptors: [])
    private var reflections: FetchedResults<Reflection>
    
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        List {
            ForEach(reflections) { reflection in
                Text(reflection.date?.formatted() ?? "")
                    .onTapGesture {
                        deleteReflections()
                    }
            }
        }
        .navigationTitle("История")
    }
    
    private func deleteReflections() {
        reflections.forEach {
            context.delete($0)
        }
        try? context.save()
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
