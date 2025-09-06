//
//  LifeAreas.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 04.09.2025.
//

import SwiftUICore

enum LifeAreas: String, CaseIterable, Identifiable {
    
    case health = "Здоровье"
    case relations = "Отношения"
    case wealth = "Достаток"
    case personal = "Личное"
    
    var color: Color {
        switch self {
        case .health: .init("Health")
        case .relations: .init("Relations")
        case .wealth: .init("Wealth")
        case .personal: .init("Personal")
        }
    }
    
    var order: Int {
        switch self {
        case .health: 0
        case .relations: 1
        case .wealth: 2
        case .personal: 3
        }
    }
    
    var id: Self { self }
}
