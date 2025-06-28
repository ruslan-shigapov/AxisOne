//
//  GoalsView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct GoalsView: View {
        
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [.init(key: "createdAt", ascending: true)])
    private var goals: FetchedResults<Goal>
    
    @State private var isModalViewPresented = false
    
    var body: some View {
        List {
            ForEach(Constants.LifeAreas.allCases) { lifeArea in
                Section {
                    ForEach(goals.filter { $0.lifeArea == lifeArea.rawValue }) {
                        GoalView(goal: $0)
                    }
                } header: {
                    LabeledContent {
                        ProgressView(value: calculateProgress(for: lifeArea))
                            .frame(width: 150)
                            .tint(lifeArea.color)
                    } label: {
                        Text(lifeArea.rawValue)
                            .font(.callout)
                            .foregroundColor(lifeArea.color)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    isModalViewPresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isModalViewPresented) {
            DetailGoalView()
        }
    }
    
    private func calculateProgress(
        for lifeArea: Constants.LifeAreas
    ) -> Double {
        let filteredGoals = goals.filter { $0.lifeArea == lifeArea.rawValue }
        let completedGoals = filteredGoals.filter(\.isCompleted)
        return Double(completedGoals.count) / Double(filteredGoals.count)
        // TODO: add subgoals calculation ?
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
