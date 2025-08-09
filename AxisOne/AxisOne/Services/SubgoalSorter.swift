//
//  SubgoalSorter.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 08.08.2025.
//

import Foundation

struct SubgoalSorter {
    
    static func compare(lhs: Subgoal, rhs: Subgoal) -> Bool {
        if let lhsTime = lhs.time, let rhsTime = rhs.time {
            if lhsTime != rhsTime {
                return lhsTime < rhsTime
            }
        } else if let _ = lhs.time {
            return true
        } else if let _ = rhs.time {
            return false
        }
        if let lhsRawValue = Constants.TimesOfDay(
            rawValue: lhs.timeOfDay ?? ""),
           let rhsRawValue = Constants.TimesOfDay(
            rawValue: rhs.timeOfDay ?? ""),
           lhsRawValue != rhsRawValue {
            return lhsRawValue.order < rhsRawValue.order
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
