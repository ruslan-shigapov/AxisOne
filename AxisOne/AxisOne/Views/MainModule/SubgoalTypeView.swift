//
//  SubgoalTypeView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 13.07.2025.
//

import SwiftUI

struct SubgoalTypeView: View {
    
    @FetchRequest
    private var subgoals: FetchedResults<Subgoal>
    
    private var filteredSubgoals: [Subgoal] {
        subgoals.filter { $0.type == type.rawValue }
    }
    
    var type: Constants.SubgoalTypes
    var date: Date
    
    var body: some View {
        NavigationStack {
            List {
                let uncompletedSubgoals = filteredSubgoals.filter {
                    !$0.isCompleted
                }
                Section(type.plural) {
                    if uncompletedSubgoals.isEmpty {
                        Text("Подцелей данного типа не имеется")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(uncompletedSubgoals) {
                            SubgoalView(subgoal: $0)
                        }
                    }
                }
                let completedSubgoals = filteredSubgoals.filter { $0.isCompleted }
                if !completedSubgoals.isEmpty {
                    Section("Выполнено") {
                        ForEach(completedSubgoals) {
                            SubgoalView(subgoal: $0)
                        }
                    }
                }
            }
            .navigationTitle(getTitle())
            .navigationBarTitleDisplayMode(.inline)
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
    
    private func getTitle() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Сегодня"
        } else if calendar.isDateInTomorrow(date) {
            return "Завтра"
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
