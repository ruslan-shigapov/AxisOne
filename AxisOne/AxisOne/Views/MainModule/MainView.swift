//
//  MainView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct MainView: View {
    
    // MARK: - Private Properties
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [.init(key: "time", ascending: true)],
        predicate: SubgoalFilter.predicate(for: .now))
    private var subgoals: FetchedResults<Subgoal>
        
    private var currentSubgoals: [Subgoal] {
        let subgoalsByExactTime = subgoals.filter {
            let subgoalTime = Constants.TimesOfDay.getTimeOfDay(from: $0.time)
            return subgoalTime == Constants.TimesOfDay.getTimeOfDay(from: Date())
        }
        let subgoalsByTimeOfDay = subgoals.filter {
            $0.timeOfDay == Constants.TimesOfDay.getTimeOfDay(
                from: Date()).rawValue
        }
        return subgoalsByExactTime + subgoalsByTimeOfDay
    }
    
    @State private var selectedDate = Date()
    
    @State private var selectedSubgoalType: Constants.SubgoalTypes?
    
    @State private var isDatePickerPresented = false
    
    // MARK: - Body
    var body: some View {
        SubgoalListView()
            .toolbar {
                ToolbarItem {
                    
                }
                ToolbarItem {
                    Button {
                        isDatePickerPresented = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                    .popover(isPresented: $isDatePickerPresented) {
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .onChange(of: selectedDate) {
                                subgoals.nsPredicate = SubgoalFilter.predicate(
                                    for: selectedDate)
                            }
                            .environment(
                                \.locale,
                                 Locale(identifier: "ru_RU"))
                    }
                }
                ToolbarItem {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(item: $selectedSubgoalType) {
                SubgoalTypeView(type: $0, date: selectedDate)
            }
    }
    
    // MARK: - Private Methods
    private func getSubgoalCount(_ subgoalType: Constants.SubgoalTypes) -> Int {
        subgoals
            .filter { $0.type == subgoalType.rawValue }
            .filter { !$0.isCompleted }
            .count
    }
}

// MARK: - Views
private extension MainView {
    
    func SubgoalTypeGridView() -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]) {
                ForEach(Constants.SubgoalTypes.allCases) { type in
                    SubgoalTypeCardView(type, count: getSubgoalCount(type))
                        .onTapGesture {
                            selectedSubgoalType = type
                        }
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color(.systemBackground))
    }
    
    func SubgoalTypeCardView(
        _ subgoalType: Constants.SubgoalTypes,
        count: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: subgoalType.imageName)
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                Spacer()
                Text(String(count))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            Text(subgoalType.plural)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        }
    }
    
    func SubgoalListView() -> some View {
        List {
            Section("Сегодня") {
                SubgoalTypeGridView()
            }
            let uncompletedSubgoals = currentSubgoals.filter { !$0.isCompleted }
            Section(Constants.TimesOfDay.getTimeOfDay(from: Date()).rawValue) {
                if uncompletedSubgoals.isEmpty {
                    Text("Время дня свободно")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(uncompletedSubgoals) {
                        SubgoalView(subgoal: $0)
                    }
                }
            }
            let completedSubgoals = currentSubgoals.filter { $0.isCompleted }
            if !completedSubgoals.isEmpty {
                Section("Выполнено") {
                    ForEach(completedSubgoals) {
                        SubgoalView(subgoal: $0)
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
