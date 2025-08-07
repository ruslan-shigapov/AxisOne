//
//  InboxView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 27.07.2025.
//

import SwiftUI

struct InboxView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [.init(key: "time", ascending: true)],
        predicate: NSPredicate(
            format: "type == %@",
            Constants.SubgoalTypes.inbox.rawValue))
    private var subgoals: FetchedResults<Subgoal>
    
    private var filteredSubgoals: [Subgoal] {
        subgoals
            .filter {
                guard let deadline = $0.deadline, !$0.isCompleted else {
                    return false
                }
                return Calendar.current.isDate(deadline, inSameDayAs: date)
            }
            .sorted {
                guard let firstTimeOfDay = Constants.TimesOfDay(
                    rawValue: $0.timeOfDay ?? ""),
                      let secondTimeOfDay = Constants.TimesOfDay(
                        rawValue: $1.timeOfDay ?? "")
                else {
                    return false
                }
                return firstTimeOfDay.order < secondTimeOfDay.order
            }
    }
    
    private var uncompletedSubgoals: [Subgoal] {
        subgoals.filter {
            !$0.isCompleted && $0.deadline == nil
        }
    }
    
    private var completedSubgoals: [Subgoal] {
        subgoals.filter { $0.isCompleted }
    }
    
    var date: Date
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(
                    destination: DetailSubgoalView(
                        subgoals: .constant([]),
                        isModified: .constant(false))
                ) {
                    Text("Добавить")
                        .font(.custom("Jura-Medium", size: 17))
                        .foregroundStyle(.accent)
                }
                if !uncompletedSubgoals.isEmpty {
                    Section {
                        ForEach(uncompletedSubgoals) {
                            SubgoalView(
                                subgoal: $0,
                                isToday: Calendar.current.isDateInToday(date))
                        }
                    } header: {
                        HeaderView(text: "На очереди")
                    }
                }
                Section {
                    if filteredSubgoals.isEmpty {
                        EmptyRowTextView(
                            text: "Подцелей данного типа не имеется")
                    } else {
                        ForEach(filteredSubgoals) {
                            SubgoalView(
                                subgoal: $0,
                                isToday: Calendar.current.isDateInToday(date))
                        }
                    }
                } header: {
                    HeaderView(text: "Сегодня")
                }
                if !completedSubgoals.isEmpty {
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
            .navigationTitle(Constants.SubgoalTypes.inbox.rawValue)
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
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
