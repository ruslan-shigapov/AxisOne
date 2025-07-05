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
    
    private var subgoals: [Subgoal] {
        goals
            .compactMap { $0.subgoals as? Set<Subgoal> }
            .flatMap { $0 }
    }
        
    var body: some View {
        ZStack {
            if subgoals.isEmpty {
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
            Section("Активные подцели") {
                // TODO: отсортировывать по расписанию
                ForEach(subgoals) { subgoal in
                    NavigationLink(
                        destination: AnalysisView(subgoal: subgoal)
                    ) {
                        SubgoalView(subgoal: subgoal)
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
