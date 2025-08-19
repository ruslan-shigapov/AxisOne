//
//  SubgoalTypesView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 16.08.2025.
//

import SwiftUI

struct SubgoalTypesView: View {
    
    @FetchRequest
    private var subgoals: FetchedResults<Subgoal>
    
    @Binding var selectedType: Constants.SubgoalTypes?
    
    let date: Date
    
    var body: some View {
        HStack {
            ForEach(Constants.SubgoalTypes.allCases) { type in
                SubgoalTypeCircleView(type: type, count: getSubgoalCount(type))
                    .onTapGesture {
                        selectedType = type
                    }
            }
        }
    }
    
    init(selectedType: Binding<Constants.SubgoalTypes?>, date: Date) {
        self._selectedType = selectedType
        self.date = date
        _subgoals = FetchRequest(
            entity: Subgoal.entity(),
            sortDescriptors: [],
            predicate: SubgoalFilter.predicate(
                for: date,
                types: Constants.SubgoalTypes.allCases))
    }
    
    private func getSubgoalCount(_ type: Constants.SubgoalTypes) -> Int {
        subgoals
            .filter { $0.type == type.rawValue }
            .filter { !$0.isCompleted || !Calendar.current.isDateInToday(date) }
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
            .count
    }
}
