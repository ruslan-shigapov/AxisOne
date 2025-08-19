//
//  GoalListView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 18.08.2025.
//

import SwiftUI

struct GoalListView: View {
    
    // MARK: - Private Properties
    @Environment(\.managedObjectContext) private var context
    
    @AppStorage("isHealthSectionExpanded")
    private var isHealthSectionExpanded = true
    @AppStorage("isRelationsSectionExpanded")
    private var isRelationsSectionExpanded = true
    @AppStorage("isWealthSectionExpanded")
    private var isWealthSectionExpanded = true
    @AppStorage("isPersonalSectionExpanded")
    private var isPersonalSectionExpanded = true
    
    // MARK: - Public Properties
    let goals: FetchedResults<Goal>
    let isEditMode: Bool
    let isCompletedHidden: Bool
    
    // MARK: - Body
    var body: some View {
        List {
            ForEach(Constants.LifeAreas.allCases.filter { lifeArea in
                goals.contains { $0.lifeArea == lifeArea.rawValue }
            }) { lifeArea in
                var filteredGoals = getGoals(for: lifeArea)
                    .filter {
                        !isEditMode && !isCompletedHidden || !$0.isCompleted
                    }
                    .sorted {
                        if $0.isCompleted != $1.isCompleted {
                            !$0.isCompleted
                        } else {
                            $0.order < $1.order
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
                        do {
                            try context.save()
                        } catch {
                            print("Error goal moving: \(error)")
                        }
                    }
                    .moveDisabled(!isEditMode)
                } header: {
                    SectionHeaderView(for: lifeArea)
                }
            }
        }
        .listStyle(.sidebar)
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
    
    private func getProgress(for lifeArea: Constants.LifeAreas) -> Double {
        let filteredGoals = getGoals(for: lifeArea)
        let completedGoals = filteredGoals.filter(\.isCompleted)
        return Double(completedGoals.count) / Double(filteredGoals.count)
    }
}

// MARK: - Views
private extension GoalListView {
        
    func SectionHeaderView(for lifeArea: Constants.LifeAreas) -> some View {
        LabeledContent {
            ProgressView(value: getProgress(for: lifeArea))
                .frame(width: 150)
                .tint(lifeArea.color)
        } label: {
            Text(lifeArea.rawValue)
                .font(Constants.Fonts.juraMediumSubheadline)
                .foregroundColor(lifeArea.color)
        }
        .padding(.trailing, 8)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
