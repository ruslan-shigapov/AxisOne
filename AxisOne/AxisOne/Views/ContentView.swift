//
//  ContentView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 27.06.2025.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Private Properties
    @Environment(\.subgoalService) private var subgoalService
    
    @State private var selectedTab: Constants.Tabs = .main
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Constants.Tabs.allCases) { tab in
                NavigationStack {
                    tab.view
                        .navigationTitle(tab != .main ? tab.rawValue : "")
                        .background {
                            Constants.Colors.darkBackground.verticalGradient()
                                .ignoresSafeArea()
                        }
                        .scrollContentBackground(.hidden)
                }
                .tabItem {
                    Label(tab.rawValue, systemImage: tab.iconName)
                }
            }
        }
        .onAppear {
            do {
                try subgoalService.resetHabitsIfNeeded()
            } catch {
                print(error)
            }
        }
    }
    
    // MARK: - Initialize
    init() {
        setupNavBarAppearance()
        setupTabBarAppearance()
        setupSegmentedControlAppearance()
    }
    
    // MARK: - Private Methods     
    private func setupNavBarAppearance() {
        guard let largeTitleFont = UIFont(name: "Jura-Bold", size: 34) else {
            return
        }
        guard let titleFont = UIFont(name: "Jura-Bold", size: 17) else {
            return
        }
        guard let backButtonFont = UIFont(name: "Jura-Medium", size: 17) else {
            return
        }
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundEffect = UIBlurEffect(
            style: .systemUltraThinMaterial)
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
        tabBarAppearance.backgroundEffect = UIBlurEffect(
            style: .systemUltraThinMaterial)
        let itemAppearance = tabBarAppearance.stackedLayoutAppearance
        itemAppearance.normal.titleTextAttributes = [.font: titleFont]
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
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
