//
//  SubgoalListSectionsView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 17.08.2025.
//

import SwiftUI

struct SubgoalListSectionsView: View {
    
    let date: Date
    let subgoals: FetchedResults<Subgoal>
    let title: String
    let emptyRowText: String
    let isCompletedHidden: Bool
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var filteredSubgoals: [Subgoal] {
        isToday ? subgoals.filter { !$0.isCompleted } : Array(subgoals)
            .filter {
                if $0.type == Constants.SubgoalTypes.habit.rawValue {
                    guard let startDate = $0.startDate,
                          let frequency = Constants.Frequencies(
                            rawValue: $0.frequency ?? ""
                    ) else {
                        return false
                    }
                    return frequency.getNecessity(
                        on: date,
                        startDate: startDate)
                }
                return true
            }
            .sorted(by: SubgoalSorter.compare)
    }
    
    private var completedSubgoals: [Subgoal] {
        subgoals
            .filter { $0.isCompleted }
            .sorted(by: SubgoalSorter.compare)
    }
    
    var body: some View {
        Section {
            if filteredSubgoals.isEmpty {
                RowLabelView(type: .empty, text: emptyRowText)
            } else {
                ForEach(filteredSubgoals) {
                    SubgoalView(subgoal: $0, isToday: isToday)
                }
            }
        } header: {
            HeaderView(text: title)
        }
        if !completedSubgoals.isEmpty, !isCompletedHidden, isToday {
            Section {
                ForEach(completedSubgoals) {
                    SubgoalView(subgoal: $0, isToday: isToday)
                }
            } header: {
                HeaderView(text: "Выполнено")
            }
        }
    }
}
