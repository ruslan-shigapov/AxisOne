//
//  SubgoalFilter.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 12.07.2025.
//

import Foundation

struct SubgoalFilter {
    
    static func predicate(for date: Date) -> NSPredicate {
        var predicates = [NSPredicate]()
        if let interval = Calendar.current.dateInterval(of: .day, for: date) {
            predicates.append(
                NSPredicate(
                    format: "time >= %@ AND time < %@",
                    argumentArray: [interval.start, interval.end]))
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
