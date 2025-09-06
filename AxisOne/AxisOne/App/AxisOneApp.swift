//
//  AxisOneApp.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 27.06.2025.
//

import SwiftUI

@main
struct AxisOneApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                     PersistenceController.shared.container.viewContext)
        }
    }
    
    init() {
        setupNavBarAppearance()
        setupSegmentedControlAppearance()
    }
    
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
            for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.font: titleFont],
            for: .selected)
    }
}
