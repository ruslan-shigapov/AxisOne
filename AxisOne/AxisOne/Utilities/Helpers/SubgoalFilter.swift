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
        timeOfDay: TimesOfDay? = nil,
        types: [SubgoalTypes]
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
                NSPredicate(format: "type == %@", SubgoalTypes.habit.rawValue),
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
        let timeOfDayPredicate: NSPredicate? = {
            guard let timeOfDay else { return nil }
            if Calendar.current.isDateInToday(date) {
                return NSCompoundPredicate(
                    orPredicateWithSubpredicates: [
                        NSPredicate(
                            format: "todayMoved != nil AND todayMoved == %@",
                            timeOfDay.rawValue),
                        NSPredicate(
                            format: "todayMoved == nil AND timeOfDay == %@",
                            timeOfDay.rawValue)
                    ])
            } else if Calendar.current.isDateInYesterday(date) {
                return NSCompoundPredicate(
                    orPredicateWithSubpredicates: [
                        NSPredicate(
                            format: """
                            yesterdayMoved != nil AND yesterdayMoved == %@
                            """,
                            timeOfDay.rawValue),
                        NSPredicate(
                            format: "yesterdayMoved == nil AND timeOfDay == %@",
                            timeOfDay.rawValue)
                    ])
            } else {
                return NSPredicate(
                    format: "timeOfDay == %@",
                    timeOfDay.rawValue)
            }
        }()
        let typesPredicate: NSPredicate? = {
            guard !types.isEmpty else { return nil }
            return NSPredicate(format: "type IN %@", types.map { $0.rawValue })
        }()
        var predicates: [NSPredicate] = [basePredicate]
        if let timeOfDayPredicate {
            predicates.append(timeOfDayPredicate)
        }
        if let typesPredicate {
            predicates.append(typesPredicate)
        }
        let combinedPredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: predicates)
        return types.contains(.focus)
        ? NSCompoundPredicate(
            orPredicateWithSubpredicates: [
                combinedPredicate,
                NSPredicate(format: "type == %@", SubgoalTypes.focus.rawValue)
            ])
        : combinedPredicate
    }
}
