//
//  JournalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct JournalView: View {
    
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [],
        predicate: SubgoalFilter.predicate(
            for: .now,
            types: [.task, .habit, .milestone, .inbox]))
    private var subgoals: FetchedResults<Subgoal>
    
    @FetchRequest(
        entity: Reflection.entity(),
        sortDescriptors: [],
        predicate: ReflectionFilter.predicate(for: .now))
    private var reflections: FetchedResults<Reflection>
            
    private var groupedSubgoals: [TimesOfDay: [Subgoal]] {
        Dictionary(grouping: subgoals) {
            if let exactTime = $0.time {
                return TimesOfDay.getValue(from: exactTime)
            } else if let timeOfDay = $0.timeOfDay {
                return TimesOfDay(rawValue: timeOfDay) ?? .unknown
            }
            return .unknown
        }
    }
    
    var body: some View {
        ZStack {
            if groupedSubgoals.isEmpty {
                EmptyStateView(
                    primaryText: """
                    На сегодня нет активных подцелей для самоанализа
                    """)
            } else {
                List {
                    // TODO: может стоит объединить эти вью?
                    TimeOfDaySectionView(
                        groupedSubgoals: groupedSubgoals,
                        reflections: reflections)
                    SummarySectionView(
                        groupedSubgoals: groupedSubgoals,
                        reflections: reflections,
                        subgoals: subgoals)
                }
            }
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: HistoryView()) {
                    ToolbarButtonImageView(type: .history)
                }
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
