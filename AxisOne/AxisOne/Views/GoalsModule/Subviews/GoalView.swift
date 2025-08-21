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
    
    private var lifeAreaColor: Color {
        Constants.LifeAreas(rawValue: goal.lifeArea ?? "")?.color ?? .primary
    }
    
    @ObservedObject var goal: Goal
    
    var body: some View {
        HStack(spacing: 12) {
            CheckmarkImageView(isCompleted: goal.isCompleted)
                .onTapGesture {
                    withAnimation(.snappy) {
                        do {
                            try goalService.toggleComplete(of: goal)
                        } catch {
                            print(error)
                        }
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
                    do {
                        try goalService.toggleActive(of: goal)
                    } catch {
                        print(error)
                    }
                }
            }
            SwipeActionButtonView(type: .delete) {
                do {
                    try goalService.delete(goal)
                } catch {
                    print(error)
                }
            }
        }
        .sheet(isPresented: $isModalViewPresented) {
            DetailGoalView(goal: goal)
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
