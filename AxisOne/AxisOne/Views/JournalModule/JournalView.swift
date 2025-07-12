//
//  JournalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct JournalView: View {
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isActive == true"))
    private var goals: FetchedResults<Goal>
        
    var body: some View {
        ZStack {
            if goals.isEmpty {
                EmptyStateView()
            } else {
                SubgoalListView()
            }
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: HistoryView()) {
                    Image(systemName: "clock")
                }
            }
        }
    }
    
    func EmptyStateView() -> some View {
        Text("На сегодня нет активных подцелей для самоанализа")
            .frame(width: 230)
            .multilineTextAlignment(.center)
            .fontWeight(.medium)
    }
    
    func SubgoalListView() -> some View {
        List {
            Section("Активные цели") {
                ForEach(goals) { goal in
                    NavigationLink(
                        destination: AnalysisView(goal: goal)
                    ) {
                        Text(goal.title ?? "")
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
