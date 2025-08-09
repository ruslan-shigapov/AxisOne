//
//  GoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct GoalView: View {
    
    // MARK: - Private Properties
    @Environment(\.managedObjectContext) private var context
    
    @State private var isModalViewPresented = false
    
    private var lifeAreaColor: Color {
        Constants.LifeAreas(rawValue: goal.lifeArea ?? "")?
            .color ?? .secondary
    }
    
    // MARK: - Public Properties
    @ObservedObject var goal: Goal
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            CheckmarkImageView(isCompleted: $goal.isCompleted)
                .onTapGesture {
                    withAnimation {
                        toggleCompletion()
                    }
                }
            ListRowTextView(
                primaryText: goal.title,
                secondaryText: goal.notes,
                isActive: $goal.isActive,
                isCompleted: $goal.isCompleted,
                activeColor: lifeAreaColor)
            .onTapGesture {
                isModalViewPresented = true
            }
        }
        .padding(12)
        .listRowInsets(EdgeInsets())
        .swipeActions {
            if !goal.isCompleted {
                SwipeActionButtonView(
                    type: .toggleActive,
                    isActive: $goal.isActive,
                    activationColor: lifeAreaColor
                ) {
                    toggleActive()
                }
            }
            SwipeActionButtonView(type: .delete) {
                delete()
            }
        }
        .sheet(isPresented: $isModalViewPresented) {
            DetailGoalView(goal: goal)
        }
    }
    
    // MARK: - Private Methods
    private func toggleCompletion() {
        goal.isCompleted.toggle()
        if goal.isCompleted {
            goal.isActive = false
            goal.subgoals?.forEach {
                ($0 as? Subgoal)?.isActive = false
            }
        }
        goal.order = getOrder()
        try? context.save()
    }
    
    private func getOrder() -> Int16 {
        guard let lifeArea = goal.lifeArea else { return 0 }
        let fetchRequest = Goal.fetchRequest()
        fetchRequest.predicate = .init(
            format: "lifeArea == %@",
            argumentArray: [lifeArea])
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: true)]
        let lastGoal = try? context.fetch(fetchRequest).last
        return (lastGoal?.order ?? 0) + 1
    }
    
    private func toggleActive() {
        goal.isActive.toggle()
        goal.subgoals?.forEach {
            ($0 as? Subgoal)?.isActive.toggle()
        }
        try? context.save()
    }
    
    private func delete() {
        context.delete(goal)
        try? context.save()
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
