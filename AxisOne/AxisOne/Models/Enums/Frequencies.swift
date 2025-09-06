//
//  Frequencies.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 04.09.2025.
//

import Foundation

enum Frequencies: String, CaseIterable, Identifiable {
    
    case daily = "Ежедневно"
    case weekdays = "По будням"
    case weekends = "По выходным"
    case weekly = "Еженедельно"
    
    var id: Self { self }
    
    func isNecessary(for date: Date, startDate: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return switch self {
        case .daily: true
        case .weekdays: weekday >= 2 && weekday <= 6
        case .weekends: weekday == 1 || weekday == 7
        case .weekly:
            Calendar.current.component(.weekday, from: startDate) == weekday
        }
    }
}
