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
        sortDescriptors: [],
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
            .sorted(by: SubgoalSorter.compare)
    }
    
    private var uncompletedSubgoals: [Subgoal] {
        subgoals.filter {
            !$0.isCompleted && $0.deadline == nil
        }
    }
    
    private var completedSubgoals: [Subgoal] {
        subgoals.filter { $0.isCompleted }
    }
    
    let date: Date
    
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
                    SubgoalListView(
                        subgoals: filteredSubgoals,
                        emptyRowText: "Подцелей данного типа не имеется",
                        date: date)
                } header: {
                    HeaderView(text: "Сегодня")
                }
                if !completedSubgoals.isEmpty {
                    CompletedSectionView(
                        subgoals: completedSubgoals,
                        date: date)
                }
            }
            .navigationTitle(Constants.SubgoalTypes.inbox.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    NavBarImageButtonView(type: .cancel) {
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
