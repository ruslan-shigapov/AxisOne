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
        
    @State private var selectedDate = Date()
    
    @State private var selectedTimeOfDay = Constants.TimesOfDay.getTimeOfDay(
        from: Date())
    
    @State private var isDatePickerPresented = false
    
    @State private var selectedSubgoalType: Constants.SubgoalTypes?
    
    private var currentSubgoals: [Subgoal] {
        let subgoalsByExactTime = subgoals.filter {
            let subgoalTime = Constants.TimesOfDay.getTimeOfDay(from: $0.time)
            return subgoalTime.rawValue == selectedTimeOfDay.rawValue
        }
        let subgoalsByTimeOfDay = subgoals.filter {
            $0.timeOfDay == selectedTimeOfDay.rawValue
        }
        return subgoalsByExactTime + subgoalsByTimeOfDay
    }
    
    private var uncompletedSubgoals: [Subgoal] {
        currentSubgoals.filter { !$0.isCompleted }
    }
    
    private var completedSubgoals: [Subgoal] {
        currentSubgoals.filter { $0.isCompleted }
    }
    
    // MARK: - Body
    var body: some View {
        List {
            Section("Сегодня") {
                SubgoalTypeGridView()
            }
            Section(selectedTimeOfDay.rawValue) {
                TimeOfDayPickerView()
                SubgoalSectionView()
            }
            if !completedSubgoals.isEmpty {
                Section("Выполнено") {
                    ForEach(completedSubgoals) {
                        SubgoalView(subgoal: $0)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                CalendarButtonView()
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
        VStack {
            HStack {
                ForEach(Constants.SubgoalTypes.allCases.dropLast()) { type in
                    SubgoalTypeCardView(type, count: getSubgoalCount(type))
                        .onTapGesture {
                            selectedSubgoalType = type
                        }
                }
            }
            HStack {
                Image(systemName: Constants.SubgoalTypes.rule.imageName)
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                Text(Constants.SubgoalTypes.rule.plural)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(getSubgoalCount(.rule)))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            }
            .onTapGesture {
                selectedSubgoalType = .rule
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
    
    func TimeOfDayPickerView() -> some View {
        Picker("", selection: $selectedTimeOfDay) {
            ForEach(Constants.TimesOfDay.allCases.dropLast()) {
                Image(systemName: $0.imageName)
            }
        }
        .pickerStyle(.palette)
        .listRowInsets(EdgeInsets())
        .padding(.bottom, 10)
    }
    
    func SubgoalSectionView() -> some View {
        Group {
            if uncompletedSubgoals.isEmpty {
                Text("Время дня свободно")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(uncompletedSubgoals) {
                    SubgoalView(subgoal: $0)
                }
            }
        }
    }
    
    func CalendarButtonView() -> some View {
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
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
