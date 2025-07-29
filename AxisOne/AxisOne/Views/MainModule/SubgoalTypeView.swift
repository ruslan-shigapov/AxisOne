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
        subgoals.filter { $0.type == type.rawValue }
    }
    
    private var uncompletedSubgoals: [Subgoal] {
        filteredSubgoals.filter { !$0.isCompleted }
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
                        Text("Подцелей данного типа не имеется")
                            .font(.custom("Jura", size: 17))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(uncompletedSubgoals) {
                            SubgoalView(subgoal: $0)
                        }
                    }
                } header: {
                    Text(type.plural)
                        .font(.custom("Jura", size: 14))
                }
                if !completedSubgoals.isEmpty {
                    Section {
                        ForEach(completedSubgoals) {
                            SubgoalView(subgoal: $0)
                        }
                    } header: {
                        Text("Выполнено")
                            .font(.custom("Jura", size: 14))
                    }
                }
            }
            .navigationTitle(getTitle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .tint(.secondary)
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
