//
//  GoalListView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 18.08.2025.
//

import SwiftUI

struct GoalListView: View {
    
    // MARK: - Private Properties
    @Environment(\.goalService) private var goalService
    
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
    let isEditing: Bool
    let isCompletedHidden: Bool
    
    // MARK: - Body
    var body: some View {
        List {
            ForEach(getAvailableLifeAreas()) { lifeArea in
                var sectionGoals = getOrderedVisibleGoals(for: lifeArea)
                Section(isExpanded: getSectionExpansionState(for: lifeArea)) {
                    ForEach(sectionGoals) {
                        GoalView(goal: $0)
                    }
                    .onMove {
                        sectionGoals.move(fromOffsets: $0, toOffset: $1)
                        saveOrders(for: sectionGoals)
                    }
                    .moveDisabled(!isEditing)
                } header: {
                    SectionHeaderView(for: lifeArea)
                }
            }
        }
        .listStyle(.sidebar)
    }
    
    // MARK: - Private Methods
    private func getAvailableLifeAreas() -> [LifeAreas] {
        LifeAreas.allCases.filter { lifeArea in
            goals.contains { $0.lifeArea == lifeArea.rawValue }
        }
    }
    
    private func getOrderedVisibleGoals(for lifeArea: LifeAreas) -> [Goal] {
        getGoals(for: lifeArea)
            .filter {
                !isEditing && !isCompletedHidden || !$0.isCompleted
            }
            .sorted {
                if $0.isCompleted != $1.isCompleted {
                    !$0.isCompleted
                } else {
                    $0.order < $1.order
                }
            }
    }
    
    private func getGoals(for lifeArea: LifeAreas) -> [Goal] {
        goals.filter { $0.lifeArea == lifeArea.rawValue }
    }
    
    private func getSectionExpansionState(
        for lifeArea: LifeAreas
    ) -> Binding<Bool> {
        switch lifeArea {
        case .health: $isHealthSectionExpanded
        case .relations: $isRelationsSectionExpanded
        case .wealth: $isWealthSectionExpanded
        case .personal: $isPersonalSectionExpanded
        }
    }
    
    private func saveOrders(for goals: [Goal]) {
        for (index, goal) in goals.enumerated() {
            goal.order = Int16(index)
            do {
                try goalService.saveOrders()
            } catch {
                print(error)
            }
        }
    }
    
    private func getProgress(for lifeArea: LifeAreas) -> Double {
        let allGoals = getGoals(for: lifeArea)
        let completedGoals = allGoals.filter(\.isCompleted)
        return Double(completedGoals.count) / Double(allGoals.count)
    }
}

// MARK: - Views
private extension GoalListView {
        
    func SectionHeaderView(for lifeArea: LifeAreas) -> some View {
        LabeledContent {
            ProgressView(value: getProgress(for: lifeArea))
                .frame(width: 150)
                .tint(lifeArea.color)
        } label: {
            Text(lifeArea.rawValue)
                .font(Constants.Fonts.juraBoldSubheadline)
                .foregroundColor(lifeArea.color)
        }
        .padding(.trailing)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
