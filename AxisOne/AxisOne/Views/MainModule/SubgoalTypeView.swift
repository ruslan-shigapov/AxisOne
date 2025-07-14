//
//  SubgoalTypeView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 13.07.2025.
//

import SwiftUI

struct SubgoalTypeView: View {
    
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [.init(key: "time", ascending: true)])
    private var subgoals: FetchedResults<Subgoal>
    
    private var filteredSubgoals: [Subgoal] {
        subgoals.filter { $0.type == type.rawValue }
    }
    
    var type: Constants.SubgoalTypes
    
    var body: some View {
        List {
            let uncompletedSubgoals = filteredSubgoals.filter {
                !$0.isCompleted
            }
            if !uncompletedSubgoals.isEmpty {
                Section(type.plural) {
                    ForEach(uncompletedSubgoals) {
                        SubgoalView(subgoal: $0)
                    }
                }
            }
            let completedSubgoals = filteredSubgoals.filter { $0.isCompleted }
            if !completedSubgoals.isEmpty {
                Section("Выполнено") {
                    ForEach(completedSubgoals) {
                        SubgoalView(subgoal: $0)
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
