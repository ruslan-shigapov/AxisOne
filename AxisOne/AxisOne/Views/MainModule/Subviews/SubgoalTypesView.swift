//
//  SubgoalTypesView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 16.08.2025.
//

import SwiftUI

struct SubgoalTypesView: View {
    
    // MARK: - Private Properties
    @FetchRequest
    private var subgoals: FetchedResults<Subgoal>
    
    // MARK: - Public Properties
    @Binding var selectedType: Constants.SubgoalTypes?
    let date: Date
    
    // MARK: - Body
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
    
    // MARK: - Initialize
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
    
    // MARK: - Private Methods
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

// MARK: - Views
private extension SubgoalTypesView {
    
    func SubgoalTypeCircleView(
        type: Constants.SubgoalTypes,
        count: Int
    ) -> some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 55, height: 55)
                    .overlay {
                        Image(systemName: type.imageName)
                            .foregroundStyle(.accent)
                            .font(.system(size: 34))
                            .fontWeight(.light)
                    }
                Text("\(count)")
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .stroke(.primary, lineWidth: 0.4)
                            .frame(width: 22, height: 22)
                    }
                    .offset(x: 22, y: -22)
            }
            Text(type.plural)
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
