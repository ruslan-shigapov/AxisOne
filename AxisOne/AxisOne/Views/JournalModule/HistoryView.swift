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
            Section("") {
                ForEach(reflections) { reflection in
                    Text(reflection.date?.formatted() ?? "")
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
        }
        .navigationTitle("История")
        .background(Constants.Colors.background)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
