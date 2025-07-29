//
//  ContentView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 27.06.2025.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @AppStorage("focusOfDay")
    private var focusOfDay: String?
    
    @State private var selectedTab: Constants.Tabs = .journal
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Constants.Tabs.allCases) { tab in
                NavigationStack {
                    tab.view
                        .navigationTitle(tab.rawValue)
                        .background(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color("Background").opacity(0.45),
                                        Color("Background")
                                    ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scrollContentBackground(.hidden)
                }
                .tabItem {
                    Label(tab.rawValue, systemImage: tab.iconName)
                }
            }
        }
        .onAppear {
            resetHabitsIfNeeded()
            resetFocusOfDayIfNeeded()
        }
    }
    
    init() {
        setupNavigationBarTitle()
    }
    
    private func resetHabitsIfNeeded() {
        let fetchRequest = Subgoal.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "type == %@",
            Constants.SubgoalTypes.habit.rawValue)
        let habits = try? context.fetch(fetchRequest)
        habits?.forEach {
            guard let lastReset = $0.lastReset else {
                $0.lastReset = today
                return
            }
            if !Calendar.current.isDate(lastReset, inSameDayAs: today) {
                $0.isCompleted = false
                $0.lastReset = today
            }
        }
        try? context.save()
    }
    
    private func resetFocusOfDayIfNeeded() {
        let fetchRequest = Subgoal.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "type == %@",
            Constants.SubgoalTypes.focus.rawValue)
        let focuses = try? context.fetch(fetchRequest)
        let wasResetToday = focuses?.contains {
            guard let lastReset = $0.lastReset else {
                $0.lastReset = today
                return false
            }
            return Calendar.current.isDate(lastReset, inSameDayAs: today)
        }
        guard let wasResetToday, !wasResetToday else { return }
        focusOfDay = focuses?.randomElement()?.title
    }
    
    private func setupNavigationBarTitle() {
        guard let largeTitleFont = UIFont(name: "Jura-Bold", size: 34) else {
            return
        }
        guard let titleFont = UIFont(name: "Jura-Bold", size: 20) else {
            return
        }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [
            .font: largeTitleFont,
            .foregroundColor: UIColor.label
        ]
        appearance.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: UIColor.label
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
