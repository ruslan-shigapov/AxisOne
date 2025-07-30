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
    
    @State private var isModalPresented = false
    
    private var groupedReflections: [Date: [Reflection]] {
        Dictionary(grouping: reflections) {
            Calendar.current.startOfDay(for: $0.date ?? Date())
        }
    }
        
    var body: some View {
        List {
            Section("") {
                ForEach(
                    groupedReflections.sorted { $0.key > $1.key }, id: \.key
                ) { date, reflections in
                    HStack {
                        Text(date.formatted(date: .long, time: .omitted))
                        Spacer()
                        Text("#\(reflections.count)")
                            .fontWeight(.bold)
                            .foregroundStyle(.accent)
                    }
                    .font(.custom("Jura", size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModalPresented = true
                    }
                    .sheet(isPresented: $isModalPresented) {
                        SummaryView(date: date)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            withAnimation {
                                reflections.forEach {
                                    context.delete($0)
                                }
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
