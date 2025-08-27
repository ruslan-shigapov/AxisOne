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
            .filter {
                guard $0.type == type.rawValue else { return false }
                if date.isInRecentDates && $0.isCompleted {
                    return false
                }
                if $0.type == Constants.SubgoalTypes.habit.rawValue,
                   let startDate = $0.startDate,
                   let frequency = Constants.Frequencies(
                    rawValue: $0.frequency ?? ""
                   ) {
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
                    .offset(x: 20, y: -20)
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
