//
//  ReflectionFilter.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.07.2025.
//

import Foundation

struct ReflectionFilter {
    
    static func predicate(
        for date: Date,
        timeOfDay: TimesOfDay? = nil
    ) -> NSPredicate {
        guard let interval = Calendar.current.dateInterval(
            of: .day, for: date
        ) else {
            return NSPredicate(value: true)
        }
        let basePredicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            argumentArray: [interval.start, interval.end])
        if let timeOfDay {
            return NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    basePredicate,
                    NSPredicate(
                        format: "timeOfDay == %@",
                        timeOfDay.rawValue)])
        } else {
            return basePredicate
        }
    }
}
