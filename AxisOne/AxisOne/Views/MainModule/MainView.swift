//
//  MainView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct MainView: View {
    
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [],
        predicate: SubgoalFilter.predicate(
            for: .now,
            timeOfDay: TimesOfDay.getValue(from: .now),
            types: [.task, .habit, .milestone, .inbox]))
    private var subgoals: FetchedResults<Subgoal>
    
    @AppStorage("isCompletedSubgoalsHidden")
    private var isCompletedSubgoalsHidden: Bool = false
    
    @State private var selectedDate = Date()
    @State private var selectedTimeOfDay = TimesOfDay.getValue(from: .now)
    
    var body: some View {
        VStack {
            MainNavigationBarView(
                selectedDate: $selectedDate,
                isCompletedSubgoalsHidden: $isCompletedSubgoalsHidden,
                selectedTimeOfDay: $selectedTimeOfDay,
                subgoals: subgoals)
            List {
                SubgoalListSectionsView(
                    date: selectedDate,
                    subgoals: subgoals,
                    title: selectedTimeOfDay.rawValue,
                    emptyRowText: "Время дня свободно",
                    isCompletedHidden: isCompletedSubgoalsHidden)
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
