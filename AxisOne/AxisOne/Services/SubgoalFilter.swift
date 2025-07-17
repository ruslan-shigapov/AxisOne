//
//  SubgoalFilter.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 15.07.2025.
//

import Foundation

struct SubgoalFilter {
    
    static func predicate(
        for date: Date,
        hasRules: Bool = true,
        isActive: Bool = false
    ) -> NSPredicate {
        guard let interval = Calendar.current.dateInterval(
            of: .day, for: date
        ) else {
            return NSPredicate(value: true)
        }
        let timePredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate(
                    format: "time != nil"),
                NSPredicate(
                    format: "time >= %@ AND time < %@",
                    argumentArray: [interval.start, interval.end]),
            ])
        let deadlinePredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate(
                    format: "time == nil"),
                NSPredicate(
                    format: "deadline >= %@ AND deadline < %@",
                    argumentArray: [interval.start, interval.end]),
            ])
        let habitPredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate(format: "type == %@", "Привычка"),
                NSPredicate(
                    format: "startDate <= %@ OR startDate == nil",
                    argumentArray: [interval.end])
            ])
        let basePredicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [
                timePredicate,
                deadlinePredicate,
                habitPredicate
            ])
        let finalPredicate = hasRules
        ? NSCompoundPredicate(
            orPredicateWithSubpredicates: [
                basePredicate,
                NSPredicate(format: "type == %@", "Правило")
            ])
        : basePredicate
        return isActive
        ? NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                finalPredicate,
                NSPredicate(format: "isActive == true")
            ])
        : finalPredicate
    }
}
