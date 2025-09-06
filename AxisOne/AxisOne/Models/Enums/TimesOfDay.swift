//
//  TimesOfDay.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 04.09.2025.
//

import Foundation

enum TimesOfDay: String, CaseIterable, Identifiable {
    
    case morning = "Утро / 5:00-11:59"
    case afternoon = "День / 12:00-17:59"
    case evening = "Вечер / 18:00-22:59"
    case night = "Ночь / 23:00-4:59"
    case unknown = "Неизвестно"
    
    var imageName: String {
        switch self {
        case .morning: "sunrise.fill"
        case .afternoon: "sun.max.fill"
        case .evening: "sunset.fill"
        case .night: "moon.stars.fill"
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
    
    static func getValue(from date: Date?) -> Self {
        guard let date else { return .unknown }
        return switch Calendar.current.component(.hour, from: date) {
        case 5..<12: .morning
        case 12..<18: .afternoon
        case 18..<23: .evening
        default: .night
        }
    }
    
    static func getComparableValue(
        from date: Date,
        for subgoal: Subgoal
    ) -> Self? {
        if Calendar.current.isDateInToday(date),
           let todayMoved = subgoal.todayMoved {
            Self(rawValue: todayMoved)
        } else if Calendar.current.isDateInYesterday(date),
                  let yesterdayMoved = subgoal.yesterdayMoved {
            Self(rawValue: yesterdayMoved)
        } else {
            if let timeOfDay = subgoal.timeOfDay {
                Self(rawValue: timeOfDay)
            } else {
                nil
            }
        }
    }
}
