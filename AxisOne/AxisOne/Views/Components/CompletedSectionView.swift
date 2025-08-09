//
//  CompletedSectionView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 08.08.2025.
//

import SwiftUI

struct CompletedSectionView: View {
    
    let subgoals: [Subgoal]
    let date: Date
    
    var body: some View {
        Section {
            ForEach(subgoals.sorted(by: SubgoalSorter.compare)) {
                SubgoalView(
                    subgoal: $0,
                    isToday: Calendar.current.isDateInToday(date))
            }
        } header: {
            HeaderView(text: "Выполнено")
        }
    }
}
