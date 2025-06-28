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
                        ProgressView(value: 0) // TODO: add calculation
                            .frame(width: 150)
                    } label: {
                        Text(lifeArea.rawValue)
                            .font(.footnote)
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
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
