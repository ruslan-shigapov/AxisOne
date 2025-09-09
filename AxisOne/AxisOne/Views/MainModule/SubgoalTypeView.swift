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
    
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [],
        predicate: NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate(format: "type == %@", SubgoalTypes.inbox.rawValue),
                NSPredicate(format: "deadline == nil")
            ]))
    private var inLineSubgoals: FetchedResults<Subgoal>
    
    let type: SubgoalTypes
    let date: Date
    
    var body: some View {
        NavigationStack {
            List {
                if type == .inbox {
                    SubgoalLink()
                    if !inLineSubgoals.isEmpty {
                        InLineSection()
                    }
                }
                SubgoalSectionsView(
                    date: date,
                    subgoals: subgoals,
                    title: getHeaderText(),
                    emptyRowText: "Подцелей данного типа не имеется",
                    isCompletedHidden: false)
            }
            .navigationTitle(type.pluralValue)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("Background"))
            .scrollContentBackground(.hidden)
        }
    }
    
    init(type: SubgoalTypes, date: Date) {
        self.type = type
        self.date = date
        _subgoals = FetchRequest(
            entity: Subgoal.entity(),
            sortDescriptors: [],
            predicate: SubgoalFilter.predicate(for: date, types: [type]))
    }
    
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

private extension SubgoalTypeView {
    
    func SubgoalLink() -> some View {
        NavigationLink(
            destination: DetailSubgoalView(
                subgoals: .constant([]),
                isModified: .constant(false))
        ) {
            RowLabelView(type: .link)
        }
    }
    
    func InLineSection() -> some View {
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

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
