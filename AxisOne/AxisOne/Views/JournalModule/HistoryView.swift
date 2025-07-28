//
//  HistoryView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct HistoryView: View {

    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        entity: Reflection.entity(),
        sortDescriptors: [])
    private var reflections: FetchedResults<Reflection>
        
    var body: some View {
        List {
            ForEach(reflections) { reflection in
                Text(reflection.date?.formatted() ?? "")
                    .onTapGesture {
                        deleteReflections()
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            withAnimation {
                                context.delete(reflection)
                                try? context.save()
                            }
                        } label: { 
                            Image(systemName: "trash")
                        }
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
