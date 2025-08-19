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
        Constants.LifeAreas(rawValue: goal.lifeArea ?? "")?.color ?? .primary
    }
    
    // MARK: - Public Properties
    @ObservedObject var goal: Goal
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            CheckmarkImageView(isCompleted: goal.isCompleted)
                .onTapGesture {
                    withAnimation {
                        toggleComplete()
                    }
                }
            ListRowTextView(
                primaryText: goal.title,
                secondaryText: goal.notes,
                isActive: goal.isActive,
                isCompleted: goal.isCompleted,
                activeColor: lifeAreaColor)
            .onTapGesture {
                isModalViewPresented = true
            }
        }
        .listRowInsets(EdgeInsets())
        .padding(12)
        .swipeActions {
            if !goal.isCompleted {
                SwipeActionButtonView(
                    type: .toggleActive(isActive: goal.isActive),
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
    private func toggleComplete() {
        goal.isCompleted.toggle()
        if goal.isCompleted {
            goal.isActive = false
            goal.subgoals?.forEach {
                ($0 as? Subgoal)?.isActive = false
            }
            goal.order = getOrder()
        }
        do {
            try context.save()
        } catch {
            print("Error goal completion toggling: \(error)")
        }
    }
    
    private func getOrder() -> Int16 {
        let areaPredicate: NSPredicate
        if let lifeArea = goal.lifeArea {
            areaPredicate = .init(format: "lifeArea == %@", lifeArea)
        } else {
            areaPredicate = NSPredicate(format: "lifeArea == nil")
        }
        let fetchRequest = Goal.fetchRequest()
        fetchRequest.predicate = areaPredicate
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: false)]
        fetchRequest.fetchLimit = 1
        do {
            let lastGoal = try context.fetch(fetchRequest).first
            return (lastGoal?.order ?? 0) + 1
        } catch {
            print("Error goal order getting to complete: \(error)")
            return 0
        }
    }
    
    private func toggleActive() {
        goal.isActive.toggle()
        goal.subgoals?.forEach {
            ($0 as? Subgoal)?.isActive.toggle()
        }
        do {
            try context.save()
        } catch {
            print("Error goal activation toggling: \(error)")
        }
    }
    
    private func delete() {
        context.delete(goal)
        do {
            try context.save()
        } catch {
            print("Error goal deleting by swipe: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
