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
    
    @State private var isModalViewPresented = false
    
    @State private var isEditing = false
    @State private var editMode: EditMode = .inactive
    
    @AppStorage("isHealthSectionExpanded")
    private var isHealthSectionExpanded = true
    @AppStorage("isRelationsSectionExpanded")
    private var isRelationsSectionExpanded = true
    @AppStorage("isWealthSectionExpanded")
    private var isWealthSectionExpanded = true
    @AppStorage("isPersonalSectionExpanded")
    private var isPersonalSectionExpanded = true
    
    @Environment(\.managedObjectContext) private var context
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if goals.isEmpty {
                EmptyStateView()
            } else {
                GoalListView()
            }
        }
        .toolbar {
            ToolbarItem {
                if !goals.isEmpty {
                    EditButtonView()
                }
            }
            ToolbarItem {
                AddButtonView()
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
        switch lifeArea {
        case .health:
            return $isHealthSectionExpanded
        case .relations:
            return $isRelationsSectionExpanded
        case .wealth:
            return $isWealthSectionExpanded
        case .personal:
            return $isPersonalSectionExpanded
        }
    }
    
    private func calculateProgress(
        for lifeArea: Constants.LifeAreas
    ) -> Double {
        let filteredGoals = getGoals(for: lifeArea)
        let completedGoals = filteredGoals.filter(\.isCompleted)
        return Double(completedGoals.count) / Double(filteredGoals.count)
        // TODO: add subgoals calculation ?
    }
}

// MARK: - Views
private extension GoalsView {
    
    func EmptyStateView() -> some View {
        VStack {
            Text("Добавьте свою первую цель")
                .fontWeight(.medium)
            Text("Для этого коснитесь кнопки с плюсом.")
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }
    
    func GoalListView() -> some View {
        List {
            ForEach(Constants.LifeAreas.allCases.filter { lifeArea in
                goals.contains { $0.lifeArea == lifeArea.rawValue }
            }) { lifeArea in
                var filteredGoals = getGoals(for: lifeArea)
                    .sorted { $0.order < $1.order }
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
    
    func SectionHeaderView(
        for lifeArea: Constants.LifeAreas
    ) -> some View {
        LabeledContent {
            ProgressView(value: calculateProgress(for: lifeArea))
                .frame(width: 150)
                .tint(lifeArea.color)
        } label: {
            Text(lifeArea.rawValue)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(lifeArea.color)
        }
    }
    
    func EditButtonView() -> some View {
        Button {
            DispatchQueue.main.async {
                isEditing.toggle()
            }
            withAnimation {
                editMode = editMode == .inactive
                ? .active
                : .inactive
            }
        } label: {
            Image(systemName: "shuffle")
        }
    }
    
    func AddButtonView() -> some View {
        Button {
            isModalViewPresented = true
        } label: {
            Image(systemName: "plus")
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
