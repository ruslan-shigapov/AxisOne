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
    // MARK: Subgoal Types
    enum SubgoalTypes: String, CaseIterable, Identifiable {
        
        case task = "Задача"
        case part = "Отрезок"
        case habit = "Привычка"
        case rule = "Правило"
        
        var imageName: String {
            switch self {
            case .task: "circle.circle"
            case .part: "flag.circle"
            case .habit: "repeat.circle"
            case .rule: "bolt.circle"
            }
        }
        
        var placeholder: String {
            switch self {
            case .task: "Что нужно сделать?"
            case .part: "Опишите результат"
            case .habit: "Опишите действие"
            case .rule: "Что стоит помнить?"
            }
        }
        
        var description: String {
            switch self {
            case .task: "Каждая выполненная задача приближает вас к цели. Старайтесь продвигаться хотя бы немного вперед каждый день."
            case .part: "Когда разбиваете цель на отрезки, то она становится более достижимой. Новый отрезок можно будет добавить только после выполнения текущего."
            case .habit: "Ключом к достижению многих целей является дисциплина. Вы можете добавить до трех привычек к одной цели."
            case .rule: "Иногда недостаточно просто совершать какие-либо действия. Бывает полезно держать в фокусе смыслы или намерения, которые помогут на вашем пути."
            }
        }
        
        var id: Self { self }
    }
    // MARK: Frequencies
    enum Frequencies: String, CaseIterable, Identifiable {
        
        case daily = "Ежедневно"
        case weekdays = "По будням"
        case weekends = "По выходным"
        case weekly = "Еженедельно"
        
        var id: Self { self }
    }
}
