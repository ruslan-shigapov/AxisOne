//
//  SubgoalListView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 08.08.2025.
//

import SwiftUI

struct SubgoalListView: View {
    
    let subgoals: [Subgoal]
    let emptyRowText: String
    let date: Date
    
    var filteredSubgoals: [Subgoal] {
        subgoals.filter {
            if $0.type == Constants.SubgoalTypes.habit.rawValue {
                guard let startDate = $0.startDate,
                      let frequency = Constants.Frequencies(
                        rawValue: $0.frequency ?? ""
                ) else {
                    return false
                }
                return frequency.getNecessity(on: date, startDate: startDate)
            }
            return true
        }
    }
    
    var body: some View {
        if filteredSubgoals.isEmpty {
            RowLabelView(type: .empty, text: emptyRowText)
        } else {
            ForEach(filteredSubgoals.sorted(by: SubgoalSorter.compare)) {
                SubgoalView(
                    subgoal: $0,
                    isToday: Calendar.current.isDateInToday(date))
            }
        }
    }
}
