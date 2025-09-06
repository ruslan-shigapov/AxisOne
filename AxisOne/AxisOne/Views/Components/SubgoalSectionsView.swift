//
//  SubgoalSectionsView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 17.08.2025.
//

import SwiftUI

struct SubgoalSectionsView: View {
    
    private var filteredSubgoals: [Subgoal] {
        subgoals
            .filter {
                !(date.isInRecentDates && isCompleted($0)) && shouldInclude($0)
            }
            .sorted { SubgoalSorter.compare(lhs: $0, rhs: $1, for: date) }
    }
    
    private var completedSubgoals: [Subgoal] {
        subgoals
            .filter { isCompleted($0) && shouldInclude($0) }
            .sorted { SubgoalSorter.compare(lhs: $0, rhs: $1, for: date) }
    }
    
    let date: Date
    let subgoals: FetchedResults<Subgoal>
    let title: String
    let emptyRowText: String
    let isCompletedHidden: Bool
    
    var body: some View {
        Section {
            if filteredSubgoals.isEmpty {
                RowLabelView(type: .empty, text: emptyRowText)
            } else {
                SubgoalViews(filteredSubgoals)
            }
        } header: {
            Text(title)
                .font(Constants.Fonts.juraMediumSubheadline)
        }
        if !completedSubgoals.isEmpty,
           !isCompletedHidden,
           date.isInRecentDates {
            Section {
                SubgoalViews(completedSubgoals)
            } header: {
                Text("Выполнено")
                    .font(Constants.Fonts.juraMediumSubheadline)
            }
        }
    }
    
    private func isCompleted(_ subgoal: Subgoal) -> Bool {
        Calendar.current.isDateInYesterday(date)
        ? subgoal.wasCompleted
        : subgoal.isCompleted
    }
    
    private func shouldInclude(_ subgoal: Subgoal) -> Bool {
        if subgoal.type == SubgoalTypes.habit.rawValue,
           let startDate = subgoal.startDate,
           let frequency = Frequencies(rawValue: subgoal.frequency ?? "") {
            return frequency.isNecessary(
                for: date,
                startDate: startDate)
        }
        return true
    }
    
    private func SubgoalViews(_ subgoals: [Subgoal]) -> some View {
        ForEach(subgoals) {
            SubgoalView(subgoal: $0, currentDate: date)
        }
    }
}
