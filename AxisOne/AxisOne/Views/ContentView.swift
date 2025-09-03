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
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedTab: Constants.Tabs = .main
    
    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Constants.Tabs.allCases) { tab in
                NavigationStack {
                    ZStack(alignment: .bottom) {
                        tab.view
                            .navigationTitle(tab.rawValue)
                            .toolbar(tab == .main ? .hidden : .visible)
                            .toolbar(.hidden, for: .tabBar)
                            .background(
                                colorScheme == .dark
                                ? Constants.Colors.darkBackground
                                : Constants.Colors.lightBackground)
                            .scrollContentBackground(.hidden)
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [.clear, .black]),
                                    startPoint: .top,
                                    endPoint: .bottom))
                            .frame(height: 140)
                        TabBarView(activeTab: $selectedTab)
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
        }
    }
    
    // MARK: - Initialize
    init() {
        setupNavBarAppearance()
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
            style: .systemThickMaterial)
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
