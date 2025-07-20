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
            hasRules: false,
            isActive: true))
    private var subgoals: FetchedResults<Subgoal>
    
    @FetchRequest(
        entity: Reflection.entity(),
        sortDescriptors: [],
        predicate: ReflectionFilter.predicate(for: .now))
    private var reflections: FetchedResults<Reflection>
    
    private var groupedSubgoals: [Constants.TimesOfDay: [Subgoal]] {
        Dictionary(grouping: subgoals) {
            if let exactTime = $0.time {
                return Constants.TimesOfDay.getTimeOfDay(from: exactTime)
            } else if let timeOfDay = $0.timeOfDay {
                return Constants.TimesOfDay(rawValue: timeOfDay) ?? .unknown
            }
            return .unknown
        }
    }
        
    var body: some View {
        ZStack {
            if groupedSubgoals.isEmpty {
                EmptyStateView()
            } else {
                TimeOfDayListView()
            }
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: HistoryView()) {
                    Image(systemName: "clock")
                }
            }
        }
    }
    
    func EmptyStateView() -> some View {
        Text("На сегодня нет активных подцелей для самоанализа")
            .frame(width: 230)
            .multilineTextAlignment(.center)
            .fontWeight(.medium)
    }
    
    func TimeOfDayListView() -> some View {
        List {
            Section("Время дня") {
                ForEach(
                    Constants.TimesOfDay.allCases.filter { groupedSubgoals.keys.contains($0)
                    }) { timeOfDay in
                        NavigationLink(
                            destination: AnalysisView(
                                timeOfDay: timeOfDay,
                                subgoals: groupedSubgoals[timeOfDay] ?? [])
                        ) {
                            LabeledContent(timeOfDay.rawValue) {
                                HStack {
                                    CheckmarkImage(for: timeOfDay)
                                    Text(
                                        String(
                                            groupedSubgoals[
                                                timeOfDay
                                            ]?.count ?? 0))
                                }
                            }
                        }
                }
            }
        }
    }
    
    func CheckmarkImage(for timeOfDay: Constants.TimesOfDay) -> some View {
        groupedSubgoals.keys.contains(timeOfDay) &&
        reflections.contains(
            where: { $0.timeOfDay ?? "" == timeOfDay.rawValue })
        ? Image(systemName: "checkmark")
        : Image(systemName: "")
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
