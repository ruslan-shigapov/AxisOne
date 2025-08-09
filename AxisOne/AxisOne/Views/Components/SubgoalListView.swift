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
    
    var body: some View {
        if subgoals.isEmpty {
            RowLabelView(type: .empty, text: emptyRowText)
        } else {
            ForEach(subgoals.sorted(by: SubgoalSorter.compare)) {
                SubgoalView(
                    subgoal: $0,
                    isToday: Calendar.current.isDateInToday(date))
            }
        }
    }
}
