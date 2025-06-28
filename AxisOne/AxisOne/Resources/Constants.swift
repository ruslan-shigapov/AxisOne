//
//  Constants.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUICore

enum Constants {
    // MARK: Tabs
    enum Tabs: String, CaseIterable, Identifiable {
        
        case goals = "Цели"
        case main = "Главное"
        case journal = "Рефлексия"
        
        var iconName: String {
            switch self {
            case .goals: "circle.hexagonpath"
            case .main: "pyramid"
            case .journal: "book.pages"
            }
        }
        
        @ViewBuilder
        var view: some View {
            switch self {
            case .goals: GoalsView()
            case .main: MainView()
            case .journal: JournalView()
            }
        }
        
        var id: Self { self }
    }
    // MARK: Life Areas
    enum LifeAreas: String, CaseIterable, Identifiable {
        
        case health = "Здоровье"
        case relations = "Отношения"
        case wealth = "Достаток"
        case personal = "Личное"
        
        var color: Color {
            switch self {
            case .health: .green
            case .relations: .orange
            case .wealth: .cyan
            case .personal: .brown
            }
        }
        
        var id: Self { self }
    }
}
