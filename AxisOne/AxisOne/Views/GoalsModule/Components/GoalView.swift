//
//  GoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct GoalView: View {
    
    // MARK: - Private Properties
    @Environment(\.goalService) private var goalService

    @State private var isModalViewPresented = false
    @State private var isAlertPresented = false
    
    private var lifeAreaColor: Color? {
        LifeAreas(rawValue: goal.lifeArea ?? "")?.color
    }
    
    // MARK: - Public Properties
    @ObservedObject var goal: Goal
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            CheckmarkImageView(isCompleted: goal.isCompleted)
                .onTapGesture {
                    withAnimation(.snappy) {
                        toggleComplete()
                    }
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
        .deleteAlert(
            isPresented: $isAlertPresented,
            messageText: """
            Данное действие также приведет к удалению всех подцелей этой цели.  
            """
        ) {
            withAnimation(.snappy) {
                delete()
            }
        }
    }
    
    // MARK: - Private Methods
    private func toggleComplete() {
        do {
            try goalService.toggleComplete(of: goal)
        } catch {
            print(error)
        }
    }
    
    private func toggleActive() {
        do {
            try goalService.toggleActive(of: goal)
        } catch {
            print(error)
        }
    }
    
    private func delete() {
        do {
            try goalService.delete(goal)
        } catch {
            print(error)
        }
    }
}

// MARK: - Views
private extension GoalView {
    
    func ToggleActiveSwipeActionButton() -> some View {
        SwipeActionButtonView(
            type: .toggleActive(isActive: goal.isActive),
            activationColor: lifeAreaColor
        ) {
            withAnimation(.snappy) {
                toggleActive()
            }
        }
    }
    
    func DeleteSwipeActionButton() -> some View {
        SwipeActionButtonView(type: .delete) {
            isAlertPresented = true
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
