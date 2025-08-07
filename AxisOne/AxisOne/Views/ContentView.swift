//
//  ContentView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 27.06.2025.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Private Properties
    @Environment(\.managedObjectContext) private var context
    
    @AppStorage("focusOfDay")
    private var focusOfDay: String?
    
    @State private var selectedTab: Constants.Tabs = .journal
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Constants.Tabs.allCases) { tab in
                NavigationStack {
                    tab.view
                        .navigationTitle(tab.rawValue)
                        .background(Constants.Colors.background)
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
    
    // MARK: - Initialize
    init() {
        setupNavBarAppearance()
        setupTabBarAppearance()
        setupSegmentedControlAppearance()
    }
    
    // MARK: - Private Methods 
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
    
    private func setupNavBarAppearance() {
        guard let largeTitleFont = UIFont(name: "Jura-Bold", size: 34) else {
            return
        }
        guard let titleFont = UIFont(name: "Jura-Bold", size: 20) else {
            return
        }
        guard let backButtonFont = UIFont(name: "Jura-Medium", size: 17) else {
            return
        }
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.largeTitleTextAttributes = [
            .font: largeTitleFont,
            .foregroundColor: UIColor.label
        ]
        navBarAppearance.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: UIColor.label
        ]
        navBarAppearance.backButtonAppearance.normal.titleTextAttributes = [
            .font: backButtonFont
        ]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    
    private func setupTabBarAppearance() {
        guard let titleFont = UIFont(name: "Jura-Medium", size: 12) else {
            return
        }
        let tabBarAppearance = UITabBarAppearance()
        let itemAppearance = tabBarAppearance.stackedLayoutAppearance
        itemAppearance.normal.titleTextAttributes = [.font: titleFont]
        UITabBar.appearance().standardAppearance = tabBarAppearance
    }
    
    private func setupSegmentedControlAppearance() {
        guard let titleFont = UIFont(name: "Jura-Medium", size: 14) else {
            return
        }
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.font: titleFont],
            for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.font: titleFont],
            for: .selected
        )
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
