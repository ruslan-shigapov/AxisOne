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
    
    @AppStorage("isCompletedSubgoalsHidden")
    private var isCompletedSubgoalsHidden: Bool = false
        
    @State private var selectedDate = Date()
    
    @State private var selectedTimeOfDay = Constants.TimesOfDay.getTimeOfDay(
        from: Date())
    
    @AppStorage("isFocusesHidden")
    private var isFocusesHidden = false
    
    @AppStorage("focusOfDay")
    private var focusOfDay: String?
    
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
            Section {
                SubgoalTypeGridView()
            } header: {
                LabeledContent("Сегодня") {
                    Button {
                        withAnimation {
                            isFocusesHidden.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(isFocusesHidden ? "Показать" : "Скрыть")
                            Text("фокус")
                        }
                    }
                }
                .font(.caption)
            }
            Section(selectedTimeOfDay.rawValue) {
                TimeOfDayPickerView()
                SubgoalSectionView()
            }
            if !completedSubgoals.isEmpty && !isCompletedSubgoalsHidden {
                Section("Выполнено") {
                    ForEach(completedSubgoals) {
                        SubgoalView(subgoal: $0)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ToggleHidingCompletedButtonView()
            }
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
            if !isFocusesHidden {
                SubgoalTypeSecondaryView(.focus, count: getSubgoalCount(.focus))
                    .onTapGesture {
                        selectedSubgoalType = .focus
                    }
            }
            HStack {
                ForEach(Constants.SubgoalTypes.allCases.dropLast(2)) { type in
                    SubgoalTypePrimaryView(type, count: getSubgoalCount(type))
                        .onTapGesture {
                            selectedSubgoalType = type
                        }
                }
            }
            SubgoalTypeSecondaryView(.inbox, count: getSubgoalCount(.inbox))
                .onTapGesture {
                    selectedSubgoalType = .inbox
                }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color(.systemBackground))
    }
    
    func SubgoalTypeSecondaryView(
        _ subgoalType: Constants.SubgoalTypes,
        count: Int
    ) -> some View {
        VStack {
            HStack {
                Image(systemName: subgoalType.imageName)
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                Text(subgoalType.plural)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(count))
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            if subgoalType == .focus,
               count > 0,
               let focusOfDay,
               !focusOfDay.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Фокус дня:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(focusOfDay)
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.light)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.secondary.opacity(0.1))
                }
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        }
    }
    
    func SubgoalTypePrimaryView(
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
    
    func ToggleHidingCompletedButtonView() -> some View {
        Button {
            withAnimation {
                isCompletedSubgoalsHidden.toggle()
            }
        } label: {
            Image(systemName: isCompletedSubgoalsHidden ? "eye" : "eye.slash")
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
