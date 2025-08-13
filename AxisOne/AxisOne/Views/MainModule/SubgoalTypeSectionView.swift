//
//  SubgoalTypeSectionView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 08.08.2025.
//

import SwiftUI

struct SubgoalTypeSectionView: View {
    
    // MARK: - Private Properties
    @FetchRequest
    private var subgoals: FetchedResults<Subgoal>
    
    @AppStorage("isFocusesHidden")
    private var isFocusesHidden = false
    
    @AppStorage("focusOfDay")
    private var focusOfDay: String?
    
    // MARK: - Public Properties
    let date: Date
    
    @Binding var selectedSubgoalType: Constants.SubgoalTypes?
        
    // MARK: - Body
    var body: some View {
        Section {
            SubgoalTypeGridView()
        } header: {
            HeaderWithToggleView(
                title: TodaySectionHeaderTitleView(),
                contentName: "фокус",
                isContentHidden: $isFocusesHidden)
        }
    }
    
    // MARK: - Initialize
    init(
        date: Date,
        selectedSubgoalType: Binding<Constants.SubgoalTypes?>,
    ) {
        self.date = date
        self._selectedSubgoalType = selectedSubgoalType
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
                    return frequency.getNecessity(on: date, startDate: startDate)
                }
                return true
            }
            .count
    }
}

// MARK: - Views
extension SubgoalTypeSectionView {
    
    func SubgoalTypeGridView() -> some View {
        VStack {
            if !isFocusesHidden {
                SubgoalTypeSecondaryView(for: .focus)
            }
            HStack {
                ForEach(Constants.SubgoalTypes.allCases.dropLast(2)) { type in
                    SubgoalTypePrimaryView(for: type)
                        .onTapGesture {
                            selectedSubgoalType = type
                        }
                }
            }
            SubgoalTypeSecondaryView(for: .inbox)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
    
    func SubgoalTypePrimaryView(
        for subgoalType: Constants.SubgoalTypes
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: subgoalType.imageName)
                    .imageScale(.large)
                    .foregroundStyle(.accent)
                Spacer()
                Text(String(getSubgoalCount(subgoalType)))
                    .font(.custom("Jura-SemiBold", size: 22))
            }
            Text(subgoalType.plural)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .font(.custom("Jura", size: 17))
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        }
    }
    
    func SubgoalTypeSecondaryView(
        for subgoalType: Constants.SubgoalTypes
    ) -> some View {
        let count = getSubgoalCount(subgoalType)
        return VStack {
            HStack {
                Image(systemName: subgoalType.imageName)
                    .imageScale(.large)
                    .foregroundStyle(.accent)
                Text(subgoalType.plural)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(count))
                    .font(.custom("Jura-SemiBold", size: 22))
            }
            if subgoalType == .focus,
               count > 0,
               let focusOfDay,
               !focusOfDay.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Фокус дня:")
                        .font(.custom("Jura", size: 13))
                        .foregroundStyle(.secondary)
                    Text(focusOfDay)
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.light)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.1))
                }
            }
        }
        .font(.custom("Jura", size: 17))
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        }
        .onTapGesture {
            selectedSubgoalType = subgoalType
        }
    }
    
    func TodaySectionHeaderTitleView() -> some View {
        if Calendar.current.isDateInToday(date) {
            Text("Сегодня")
        } else if Calendar.current.isDateInTomorrow(date) {
            Text("Завтра")
        } else {
            Text(date.formatted(date: .long, time: .omitted))
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
