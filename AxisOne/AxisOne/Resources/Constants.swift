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
            case .wealth: .purple
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
            case .part: "Когда разбиваете цель на отрезки, то она становится более достижимой."
            case .habit: "Ключом к достижению многих целей является дисциплина. Вы можете добавить до трех привычек к одной цели."
            case .rule: "Иногда недостаточно просто совершать какие-либо действия. Бывает полезно держать в фокусе смыслы или намерения, которые помогут на вашем пути."
            }
        }
        
        var plural: String {
            switch self {
            case .task: "Задачи"
            case .part: "Отрезки"
            case .habit: "Привычки"
            case .rule: "Правила"
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
    // MARK: Feelings
    enum TimesOfDay: String, CaseIterable, Identifiable {
        
        case morning = "Утро / 5:00-11:59"
        case afternoon = "День / 12:00-17:59"
        case evening = "Вечер / 18:00-22:59"
        case night = "Ночь / 23:00-4:59"
        case unknown = "Неизвестно"
        
        var id: Self { self }
        
        static func getTimeOfDay(from date: Date?) -> Self {
            guard let date else { return .unknown }
            return switch Calendar.current.component(.hour, from: date) {
            case 5..<12: .morning
            case 12..<18: .afternoon
            case 18...23: .evening
            default: .night
            }
        }
    }
    // MARK: Feelings
    enum Feelings: String, CaseIterable, Identifiable {
        
        case anger = "Гнев"
        case fear = "Страх"
        case sadness = "Грусть"
        case joy = "Радость"
        case love = "Любовь"
        
        var color: Color {
            switch self {
            case .anger, .fear, .sadness: .red
            case .joy, .love: .blue
            }
        }
        
        var emotions: [String] {
            switch self {
            case .anger: ["недовольство", "досада", "раздражение", "обида", "неприязнь", "негодование", "зависть", "ревность", "злость", "возмущение", "ненависть", "ярость"]
            case .fear: ["сомнение", "неуверенность", "подозрение", "смущение", "растерянность", "замешательство", "опасение", "уязвимость", "беспокойство", "тревога", "испуг", "ужас"]
            case .sadness: ["безразличие", "скука", "отрешенность", "одиночество", "подавленность", "жалость", "сожаление", "разочарование", "вина, стыд", "печаль", "горечь", "тоска"]
            case .joy: ["облегчение", "довольство", "интерес", "любопытство", "уверенность", "вера", "удовлетворение", "приподнятость", "увлечение", "возбуждение", "восторг", "счастье"]
            case .love: ["дружелюбие", "уважение", "спокойствие", "принятие", "доверие", "благодарность", "нежность", "теплота", "очарованность", "восхищение", "гордость", "доброта"]
            }
        }
        
        var id: Self { self }
    }
}
