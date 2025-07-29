//
//  Constants.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUICore

enum Constants {
    
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
        
        var id: Self { self }
    }
    
    enum SubgoalTypes: String, CaseIterable, Identifiable {
        
        case task = "Задача"
        case habit = "Привычка"
        case milestone = "Веха"
        case focus = "Фокус"
        case inbox = "\"Входящие\""
        
        var imageName: String {
            switch self {
            case .task: "circle.circle"
            case .habit: "repeat.circle"
            case .milestone: "flag.circle"
            case .focus: "bolt.circle"
            case .inbox: "tray.circle"
            }
        }
        
        var placeholder: String {
            switch self {
            case .task: "Что нужно сделать?"
            case .habit: "Опишите действие"
            case .milestone: "Опишите результат"
            case .focus: "Что стоит помнить?"
            case .inbox: "Что нужно сделать?"
            }
        }

        var description: String {
            switch self {
            case .task: "Каждая выполненная задача приближает вас к цели. Старайтесь как можно чаще продвигаться хотя бы немного вперед."
            case .habit: "Ключом к достижению многих целей является дисциплина. Вы сможете отслеживать непрерывные периоды выполнения привычек."
            case .milestone: "Когда разбиваете цель на отрезки, то она становится более достижимой."
            case .focus: "Иногда недостаточно просто совершать действия. Бывает полезно держать в фокусе смыслы или намерения, которые помогут на вашем пути."
            case .inbox: ""
            }
        }
        
        var plural: String {
            switch self {
            case .task: "Задачи"
            case .habit: "Привычки"
            case .milestone: "Вехи"
            case .focus: "Фокусы"
            case .inbox: self.rawValue
            }
        }
        
        var id: Self { self }
    }
    
    enum Frequencies: String, CaseIterable, Identifiable {
        
        case daily = "Ежедневно"
        case weekdays = "По будням"
        case weekends = "По выходным"
        case weekly = "Еженедельно"
        
        var id: Self { self }
    }
    
    enum TimesOfDay: String, CaseIterable, Identifiable {
        
        case morning = "Утро / 5:00-11:59"
        case afternoon = "День / 12:00-17:59"
        case evening = "Вечер / 18:00-22:59"
        case night = "Ночь / 23:00-4:59"
        case unknown = "Неизвестно"
        
        var imageName: String {
            switch self {
            case .morning: "sunrise"
            case .afternoon: "sun.max"
            case .evening: "sunset"
            case .night: "moon.stars"
            case .unknown: ""
            }
        }
        
        var order: Int {
            switch self {
            case .morning: 0
            case .afternoon: 1
            case .evening: 2
            case .night: 3
            case .unknown: 4
            }
        }
        
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
    
    enum Feelings: String, CaseIterable, Identifiable {
        
        case anger = "Гнев"
        case fear = "Страх"
        case sadness = "Грусть"
        case joy = "Радость"
        
        var emotions: [String] {
            switch self {
            case .anger: ["недовольство", "огорчение", "раздражение", "обида", "неприязнь", "негодование", "зависть", "ревность", "злость", "нервозность", "отвращение", "ярость"]
            case .fear: ["сомнение", "неловкость", "подозрение", "смущение", "растерянность", "замешательство", "опасение", "уязвимость", "беспокойство", "тревога", "испуг", "ужас"]
            case .sadness: ["безразличие", "скука", "отрешенность", "одиночество", "усталость", "жалость", "сожаление", "разочарование", "вина, стыд", "печаль", "уныние", "тоска"]
            case .joy: ["облегчение", "довольство", "интерес", "любопытство", "уверенность", "вера", "удовлетворение", "веселье", "увлечение", "возбуждение", "восторг", "счастье", "удивление", "уважение", "спокойствие", "принятие", "доверие", "благодарность", "нежность", "теплота", "очарованность", "восхищение", "гордость", "доброта"]
            }
        }
        
        var id: Self { self }
    }
}
