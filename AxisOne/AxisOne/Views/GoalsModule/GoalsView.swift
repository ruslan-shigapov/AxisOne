//
//  GoalsView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct GoalsView: View {
    
    // MARK: - Private Properties
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(entity: Goal.entity(), sortDescriptors: [])
    private var goals: FetchedResults<Goal>
    
    @AppStorage("isHealthSectionExpanded")
    private var isHealthSectionExpanded = true
    @AppStorage("isRelationsSectionExpanded")
    private var isRelationsSectionExpanded = true
    @AppStorage("isWealthSectionExpanded")
    private var isWealthSectionExpanded = true
    @AppStorage("isPersonalSectionExpanded")
    private var isPersonalSectionExpanded = true

    @AppStorage("isCompletedGoalsHidden")
    private var isCompletedGoalsHidden: Bool = false
    
    @State private var isModalViewPresented = false
    
    @State private var isEditing = false
    @State private var editMode: EditMode = .inactive

    // MARK: - Body
    var body: some View {
        ZStack {
            if goals.isEmpty {
                EmptyStateView(
                    primaryText: "Добавьте свою первую цель",
                    secondaryText: "Для этого коснитесь кнопки с плюсом.")
            } else {
                GoalListView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if !goals.isEmpty {
                    NavBarLabelButtonView(
                        type: .edit,
                        isEditModeActive: editMode == .active
                    ) {
                        toggleEditMode()
                    }
                }
            }
            ToolbarItem {
                NavBarImageButtonView(
                    type: .toggleCompletedVisibility,
                    isCompletedHidden: $isCompletedGoalsHidden
                )
            }
            ToolbarItem {
                NavBarImageButtonView(type: .add) {
                    isModalViewPresented = true
                }
            }
        }
        .sheet(isPresented: $isModalViewPresented) {
            DetailGoalView()
        }
        .environment(\.editMode, $editMode)
    }
    
    // MARK: - Private Methods
    private func getGoals(for lifeArea: Constants.LifeAreas) -> [Goal] {
        goals.filter { $0.lifeArea == lifeArea.rawValue }
    }
    
    private func getSectionExpansionState(
        for lifeArea: Constants.LifeAreas
    ) -> Binding<Bool> {
        return switch lifeArea {
        case .health: $isHealthSectionExpanded
        case .relations: $isRelationsSectionExpanded
        case .wealth: $isWealthSectionExpanded
        case .personal: $isPersonalSectionExpanded
        }
    }
    
    private func calculateProgress(
        for lifeArea: Constants.LifeAreas
    ) -> Double {
        let filteredGoals = getGoals(for: lifeArea)
        let completedGoals = filteredGoals.filter(\.isCompleted)
        return Double(completedGoals.count) / Double(filteredGoals.count)
    }
    
    private func toggleEditMode() {
        DispatchQueue.main.async {
            isEditing.toggle()
        }
        withAnimation {
            editMode = editMode == .inactive
            ? .active
            : .inactive
        }
    }
}

// MARK: - Views
private extension GoalsView {
    
    func GoalListView() -> some View {
        List {
            ForEach(Constants.LifeAreas.allCases.filter { lifeArea in
                goals.contains { $0.lifeArea == lifeArea.rawValue }
            }) { lifeArea in
                var filteredGoals = getGoals(for: lifeArea)
                    .filter {
                        (!isCompletedGoalsHidden && !isEditing) || !$0.isCompleted
                    }
                    .sorted {
                        if $0.isCompleted != $1.isCompleted {
                            return !$0.isCompleted
                        } else {
                            return $0.order < $1.order
                        }
                    }
                Section(isExpanded: getSectionExpansionState(for: lifeArea)) {
                    ForEach(filteredGoals) {
                        GoalView(goal: $0)
                    }
                    .onMove {
                        filteredGoals.move(fromOffsets: $0, toOffset: $1)
                        for (index, goal) in filteredGoals.enumerated() {
                            goal.order = Int16(index)
                        }
                        try? context.save()
                    }
                    .moveDisabled(!isEditing)
                } header: {
                    SectionHeaderView(for: lifeArea)
                    Spacer()
                }
            }
        }
        .listStyle(.sidebar)
    }
    
    func SectionHeaderView(for lifeArea: Constants.LifeAreas) -> some View {
        LabeledContent {
            ProgressView(value: calculateProgress(for: lifeArea))
                .frame(width: 150)
                .tint(lifeArea.color)
        } label: {
            Text(lifeArea.rawValue)
                .font(.custom("Jura-Medium", size: 16))
                .foregroundColor(lifeArea.color)
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
