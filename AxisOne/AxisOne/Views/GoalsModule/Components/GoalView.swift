//
//  GoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct GoalView: View {
    
    @Environment(\.goalService) private var goalService

    @State private var isModalViewPresented = false
    
    private var lifeAreaColor: Color? {
        LifeAreas(rawValue: goal.lifeArea ?? "")?.color
    }
    
    @ObservedObject var goal: Goal
    
    var body: some View {
        HStack(spacing: 12) {
            CheckmarkImageView(isCompleted: goal.isCompleted)
                .onTapGesture {
                    toggleComplete()
                }
            RowTextView(
                primaryText: goal.title ?? "",
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
                ToggleActiveSwipeActionButton()
            }
            DeleteSwipeActionButton()
        }
        .sheet(isPresented: $isModalViewPresented) {
            DetailGoalView(goal: goal)
        }
    }
    
    private func toggleComplete() {
        withAnimation(.snappy) {
            do {
                try goalService.toggleComplete(of: goal)
            } catch {
                print(error)
            }
        }
    }
}

private extension GoalView {
    
    func ToggleActiveSwipeActionButton() -> some View {
        SwipeActionButtonView(
            type: .toggleActive(isActive: goal.isActive),
            activationColor: lifeAreaColor
        ) {
            do {
                try goalService.toggleActive(of: goal)
            } catch {
                print(error)
            }
        }
    }
    
    func DeleteSwipeActionButton() -> some View {
        SwipeActionButtonView(type: .delete) {
            do {
                try goalService.delete(goal)
            } catch {
                print(error)
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
