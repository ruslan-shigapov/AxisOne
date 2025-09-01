//
//  SubgoalTypeView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 13.07.2025.
//

import SwiftUI

struct SubgoalTypeView: View {
    
    // MARK: - Private Properties
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
    
    // MARK: - Public Properties
    let type: Constants.SubgoalTypes
    let date: Date
    
    // MARK: - Body
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
                        Section {
                            ForEach(inLineSubgoals) {
                                SubgoalView(subgoal: $0, currentDate: date)
                            }
                        } header: {
                            Text("На очереди")
                                .font(Constants.Fonts.juraMediumSubheadline)
                        }
                    }
                }
                SubgoalSectionsView(
                    date: date,
                    subgoals: subgoals,
                    title: getHeaderText(),
                    emptyRowText: "Подцелей данного типа не имеется",
                    isCompletedHidden: false)
            }
            .navigationTitle(type.plural)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Initialize
    init(type: Constants.SubgoalTypes, date: Date) {
        self.type = type
        self.date = date
        _subgoals = FetchRequest(
            entity: Subgoal.entity(),
            sortDescriptors: [],
            predicate: SubgoalFilter.predicate(for: date, types: [type]))
    }
    
    // MARK: - Private Methods
    private func getHeaderText() -> String {
        let calendar = Calendar.current
        return if calendar.isDateInToday(date) {
            Constants.Texts.today
        } else if calendar.isDateInYesterday(date) {
            Constants.Texts.yesterday
        } else if calendar.isDateInTomorrow(date) {
            Constants.Texts.tomorrow
        } else {
            date.formatted(date: .long, time: .omitted)
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
