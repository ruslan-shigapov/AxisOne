//
//  GoalsView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct GoalsView: View {
    
    @FetchRequest(entity: Goal.entity(), sortDescriptors: [])
    private var goals: FetchedResults<Goal>

    @AppStorage("isCompletedGoalsHidden")
    private var isCompletedGoalsHidden: Bool = false
    
    @State private var editMode: EditMode = .inactive
    @State private var isModalViewPresented = false

    var body: some View {
        ZStack {
            if goals.isEmpty {
                EmptyStateView(
                    primaryText: "Добавьте свою первую цель",
                    secondaryText: "Для этого коснитесь кнопки с плюсом.")
            } else {
                GoalListView(
                    goals: goals,
                    isEditing: editMode == .active,
                    isCompletedHidden: isCompletedGoalsHidden)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !goals.isEmpty {
                    EditToolbarButton()
                }
            }
            ToolbarItem {
                HStack(spacing: 16) {
                    ToggleVisibilityToolbarButton()
                    AddToolbarButton()
                }
            }
        }
        .sheet(isPresented: $isModalViewPresented) {
            DetailGoalView()
        }
        .environment(\.editMode, $editMode)
    }
}

private extension GoalsView {
    
    func EditToolbarButton() -> some View {
        ToolbarTextButtonView(type: .edit(isActive: editMode == .active)) {
            withAnimation(.snappy) {
                editMode = editMode == .inactive ? .active : .inactive
            }
        }
    }
    
    func ToggleVisibilityToolbarButton() -> some View {
        Button {
            withAnimation(.snappy) {
                isCompletedGoalsHidden.toggle()
            }
        } label: {
            ToolbarButtonImageView(
                type: .toggleVisibility(
                    isActive: isCompletedGoalsHidden))
        }
    }
    
    func AddToolbarButton() -> some View {
        Button {
            isModalViewPresented = true
        } label: {
            ToolbarButtonImageView(type: .add)
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
