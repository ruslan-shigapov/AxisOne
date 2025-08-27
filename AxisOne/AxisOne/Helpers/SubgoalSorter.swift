//
//  SubgoalSorter.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 08.08.2025.
//

import Foundation

struct SubgoalSorter {
    
    static func compare(lhs: Subgoal, rhs: Subgoal, for date: Date) -> Bool {
        if let lhsRawValue = Constants.TimesOfDay.getComparableTimeOfDay(
            for: lhs,
            on: date),
           let rhsRawValue = Constants.TimesOfDay.getComparableTimeOfDay(
            for: rhs,
            on: date),
           lhsRawValue != rhsRawValue {
            return lhsRawValue.order < rhsRawValue.order
        }
        if let lhsTime = lhs.time, let rhsTime = rhs.time {
            let lhsComponents = Calendar.current.dateComponents(
                [.hour, .minute],
                from: lhsTime)
            let rhsComponents = Calendar.current.dateComponents(
                [.hour, .minute],
                from: rhsTime)
            if lhsComponents.hour != rhsComponents.hour {
                return lhsComponents.hour ?? 0 < rhsComponents.hour ?? 0
            }
            if lhsComponents.minute != rhsComponents.minute {
                return lhsComponents.minute ?? 0 < rhsComponents.minute ?? 0
            }
        } else if let _ = lhs.time {
            return true
        } else if let _ = rhs.time {
            return false
        }
        if lhs.isActive != rhs.isActive {
            return lhs.isActive
        }
        if let lhsRawValue = Constants.LifeAreas(
            rawValue: lhs.goal?.lifeArea ?? ""),
           let rhsRawValue = Constants.LifeAreas(
            rawValue: rhs.goal?.lifeArea ?? "") {
            return lhsRawValue.order < rhsRawValue.order
        }
        return false
    }
}
