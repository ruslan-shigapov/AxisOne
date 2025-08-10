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
    
    @FetchRequest(
            entity: Subgoal.entity(),
            sortDescriptors: [],
            predicate: NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    NSPredicate(
                        format: "type == %@",
                        Constants.SubgoalTypes.inbox.rawValue),
                    NSPredicate(format: "deadline == nil")
                ]))
        private var inLineSubgoals: FetchedResults<Subgoal>
    
    private var completedSubgoals: [Subgoal] {
        subgoals.filter { $0.isCompleted }
    }
    
    let type: Constants.SubgoalTypes
    let date: Date
    
    var body: some View {
        NavigationStack {
            List {
                if type == .inbox {
                    NavigationLink(
                        destination: DetailSubgoalView(
                            subgoals: .constant([]),
                            isModified: .constant(false))
                    ) {
                        RowLabelView(type: .addLink)
                    }
                    if !inLineSubgoals.isEmpty {
                        SubgoalListSectionView(
                            subgoals: Array(inLineSubgoals),
                            date: date,
                            headerTitle: "На очереди")
                    }
                }
                Section {
                    SubgoalListView(
                        subgoals: subgoals.filter { !$0.isCompleted },
                        emptyRowText: "Подцелей данного типа не имеется",
                        date: date)
                } header: {
                    HeaderView(text: getHeaderText())
                }
                if !completedSubgoals.isEmpty,
                   Calendar.current.isDateInToday(date) {
                    SubgoalListSectionView(
                        subgoals: completedSubgoals,
                        date: date,
                        headerTitle: "Выполнено")
                }
            }
            .navigationTitle(type.plural)
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
    
    init(type: Constants.SubgoalTypes, date: Date) {
        self.type = type
        self.date = date
        _subgoals = FetchRequest(
            entity: Subgoal.entity(),
            sortDescriptors: [],
            predicate: SubgoalFilter.predicate(for: date, types: [type]))
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
