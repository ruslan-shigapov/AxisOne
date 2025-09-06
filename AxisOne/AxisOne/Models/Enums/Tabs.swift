//
//  Tabs.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 04.09.2025.
//

import SwiftUICore

enum Tabs: String, CaseIterable, Identifiable {
    
    case goals = "Цели"
    case main = "Главное"
    case journal = "Рефлексия"
    
    var imageName: String {
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
