//
//  GoalsView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct GoalsView: View {
    
    // MARK: - Private Properties    
    @FetchRequest(entity: Goal.entity(), sortDescriptors: [])
    private var goals: FetchedResults<Goal>

    @AppStorage("isCompletedGoalsHidden")
    private var isCompletedGoalsHidden: Bool = false
    
    @State private var editMode: EditMode = .inactive
    @State private var isModalViewPresented = false

    // MARK: - Body
    var body: some View {
        ZStack {
            if goals.isEmpty {
                EmptyStateView(
                    primaryText: "Добавьте свою первую цель",
                    secondaryText: "Для этого коснитесь кнопки с плюсом.")
            } else {
                GoalListView(
                    goals: goals,
                    isEditMode: editMode == .active,
                    isCompletedHidden: isCompletedGoalsHidden)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !goals.isEmpty {
                    NavBarTextButtonView(
                        type: .edit(isActive: editMode == .active),
                        action: toggleEditMode)
                }
            }
            ToolbarItem {
                HStack {
                    Button {
                        withAnimation {
                            isCompletedGoalsHidden.toggle()
                        }
                    } label: {
                        NavBarButtonImageView(
                            type: .toggleVisibility(
                                isActive: isCompletedGoalsHidden))
                    }
                    Button {
                        isModalViewPresented = true
                    } label: {
                        NavBarButtonImageView(type: .add)
                    }
                }
            }
        }
        .sheet(isPresented: $isModalViewPresented) {
            DetailGoalView()
        }
        .environment(\.editMode, $editMode)
    }
    
    // MARK: - Private Methods
    private func toggleEditMode() {
        DispatchQueue.main.async {
            withAnimation {
                editMode = editMode == .inactive ? .active : .inactive
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
