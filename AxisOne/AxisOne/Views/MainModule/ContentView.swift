//
//  ContentView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 27.06.2025.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @State private var selectedTab: Constants.Tabs = .main
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Constants.Tabs.allCases) { tab in
                NavigationStack {
                    tab.view
                        .navigationTitle(tab.rawValue)
                }
                .tabItem {
                    Label(tab.rawValue, systemImage: tab.iconName)
                }
            }
        }
        .onAppear {
            resetHabitsIfNeeded()
        }
    }
    
    private func resetHabitsIfNeeded() {
        let fetchRequest = Subgoal.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "type == %@",
            Constants.SubgoalTypes.habit.rawValue)
        let habits = try? context.fetch(fetchRequest)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        habits?.forEach {
            guard let lastReset = $0.lastReset else {
                $0.lastReset = today
                return
            }
            if !calendar.isDate(lastReset, inSameDayAs: today) {
                $0.isCompleted = false
                $0.lastReset = today
            }
        }
        try? context.save()
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
