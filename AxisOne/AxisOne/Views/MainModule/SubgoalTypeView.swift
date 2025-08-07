//
//  SubgoalTypeView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 13.07.2025.
//

import SwiftUI

struct SubgoalTypeView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest
    private var subgoals: FetchedResults<Subgoal>
    
    private var filteredSubgoals: [Subgoal] {
        subgoals
            .filter { $0.type == type.rawValue }
            .sorted {
                guard let firstTimeOfDay = Constants.TimesOfDay(
                    rawValue: $0.timeOfDay ?? ""),
                      let secondTimeOfDay = Constants.TimesOfDay(
                        rawValue: $1.timeOfDay ?? "")
                else {
                    return false
                }
                if firstTimeOfDay.order != secondTimeOfDay.order {
                    return firstTimeOfDay.order < secondTimeOfDay.order
                }
                guard let firstLifeArea = Constants.LifeAreas(
                    rawValue: $0.goal?.lifeArea ?? ""),
                      let secondLifeArea = Constants.LifeAreas(
                        rawValue: $1.goal?.lifeArea ?? "")
                else {
                    return false
                }
                return firstLifeArea.order < secondLifeArea.order
            }
    }
    
    private var uncompletedSubgoals: [Subgoal] {
        if Calendar.current.isDateInToday(date) {
            return filteredSubgoals.filter { !$0.isCompleted }
        }
        return filteredSubgoals
    }
    
    private var completedSubgoals: [Subgoal] {
        filteredSubgoals.filter { $0.isCompleted }
    }
    
    var type: Constants.SubgoalTypes
    var date: Date
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if uncompletedSubgoals.isEmpty {
                        EmptyRowTextView(
                            text: "Подцелей данного типа не имеется")
                    } else {
                        ForEach(uncompletedSubgoals) {
                            SubgoalView(
                                subgoal: $0,
                                isToday: Calendar.current.isDateInToday(date))
                        }
                    }
                } header: {
                    HeaderView(text: getHeaderText())
                }
                if !completedSubgoals.isEmpty,
                   Calendar.current.isDateInToday(date) {
                    Section {
                        ForEach(completedSubgoals) {
                            SubgoalView(
                                subgoal: $0,
                                isToday: Calendar.current.isDateInToday(date))
                        }
                    } header: {
                        HeaderView(text: "Выполнено")
                    }
                }
            }
            .navigationTitle(type.plural)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    ToolbarButtonView(type: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    init(type: Constants.SubgoalTypes, date: Date) {
        self.type = type
        self.date = date
        _subgoals = FetchRequest(
            entity: Subgoal.entity(),
            sortDescriptors: [.init(key: "time", ascending: true)],
            predicate: SubgoalFilter.predicate(for: date))
    }
    
    private func getHeaderText() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Сегодня"
        } else if calendar.isDateInTomorrow(date) {
            return "Завтра"
        }
        return date.formatted(date: .long, time: .omitted)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
