//
//  InboxView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 27.07.2025.
//

import SwiftUI

struct InboxView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [.init(key: "time", ascending: true)],
        predicate: NSPredicate(
            format: "type == %@",
            Constants.SubgoalTypes.inbox.rawValue))
    private var subgoals: FetchedResults<Subgoal>
    
    private var filteredSubgoals: [Subgoal] {
        subgoals.filter {
            guard let deadline = $0.deadline, !$0.isCompleted else {
                return false
            }
            return Calendar.current.isDate(deadline, inSameDayAs: date)
        }
    }
    
    private var uncompletedSubgoals: [Subgoal] {
        subgoals.filter {
            !$0.isCompleted && $0.deadline == nil
        }
    }
    
    private var completedSubgoals: [Subgoal] {
        subgoals.filter { $0.isCompleted }
    }
    
    var date: Date
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(
                    destination: DetailSubgoalView(
                        subgoals: .constant([]),
                        isModified: .constant(false))
                ) {
                    Text("Добавить")
                        .foregroundStyle(.blue)
                }
                if !uncompletedSubgoals.isEmpty {
                    Section("На очереди") {
                        ForEach(uncompletedSubgoals) {
                            SubgoalView(subgoal: $0)
                        }
                    }
                }
                Section("Сегодня") {
                    if filteredSubgoals.isEmpty {
                        Text("Подцелей данного типа не имеется")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(filteredSubgoals) {
                            SubgoalView(subgoal: $0)
                        }
                    }
                }
                if !completedSubgoals.isEmpty {
                    Section("Выполнено") {
                        ForEach(completedSubgoals) {
                            SubgoalView(subgoal: $0)
                        }
                    }
                }
            }
            .navigationTitle(Constants.SubgoalTypes.inbox.rawValue)
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
