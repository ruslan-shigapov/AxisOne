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
    
    let date: Date
    
    var body: some View {
        HStack {
            ForEach(SubgoalTypes.allCases) { type in
                NavigationLink(
                    destination: SubgoalTypeView(type: type, date: date)
                ) {
                    SubgoalTypeCircleView(
                        type: type,
                        count: getSubgoalCount(type))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    init(date: Date) {
        self.date = date
        _subgoals = FetchRequest(
            entity: Subgoal.entity(),
            sortDescriptors: [],
            predicate: SubgoalFilter.predicate(
                for: date,
                types: SubgoalTypes.allCases))
    }
    
    private func getSubgoalCount(_ type: SubgoalTypes) -> Int {
        subgoals
            .filter {
                guard $0.type == type.rawValue else { return false }
                if date.isInRecentDates && $0.isCompleted {
                    return false
                }
                if $0.type == SubgoalTypes.habit.rawValue,
                   let startDate = $0.startDate,
                   let frequency = Frequencies(rawValue: $0.frequency ?? "") {
                    return frequency.isNecessary(
                        for: date,
                        startDate: startDate)
                }
                return true
            }
            .count
    }
}

private extension SubgoalTypesView {
    
    func SubgoalTypeCircleView(
        type: SubgoalTypes,
        count: Int
    ) -> some View {
        VStack {
            ZStack {
                Circle()
                    .fill(.accent)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: type.imageName)
                            .foregroundStyle(.white)
                            .font(.system(size: 50, weight: .ultraLight))
                    }
                Text("\(count)")
                    .background {
                        Circle()
                            .fill(.thickMaterial)
                            .stroke(.primary, lineWidth: 0.3)
                            .frame(width: 22, height: 22)
                    }
                    .offset(x: 20, y: -18)
            }
            Text(type.pluralValue)
        }
        .font(Constants.Fonts.juraMediumFootnote)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
