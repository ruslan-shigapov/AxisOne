//
//  SubgoalTypes.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 04.09.2025.
//

enum SubgoalTypes: String, CaseIterable, Identifiable {
    
    case task = "Задача"
    case habit = "Привычка"
    case milestone = "Веха"
    case focus = "Фокус"
    case inbox = "Входящее"
    
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

    var tip: String {
        switch self {
        case .task: """
        Каждая выполненная задача приближает вас к цели. \
        Старайтесь как можно чаще продвигаться хотя бы немного вперед.
        """
        case .habit: """
        Ключом к достижению многих целей является дисциплина. \
        Вы сможете отслеживать непрерывные периоды выполнения привычек.
        """
        case .milestone: """
        Когда разбиваете цель на отрезки, то она становится более достижимой.
        """
        case .focus: """
        Иногда недостаточно просто совершать действия. \
        Бывает полезно держать в фокусе смыслы или намерения, \
        которые помогут на вашем пути.
        """
        case .inbox: ""
        }
    }
    
    var pluralValue: String {
        switch self {
        case .task: "Задачи"
        case .habit: "Привычки"
        case .milestone: "Вехи"
        case .focus: "Фокусы"
        case .inbox: "Входящие"
        }
    }
    
    var id: Self { self }
}
