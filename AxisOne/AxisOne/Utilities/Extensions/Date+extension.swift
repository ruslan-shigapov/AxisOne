//
//  Date+extension.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 25.08.2025.
//

import Foundation

extension Date {

    var isInRecentDates: Bool {
        Calendar.current.isDateInToday(self) ||
        Calendar.current.isDateInYesterday(self)
    }
}
