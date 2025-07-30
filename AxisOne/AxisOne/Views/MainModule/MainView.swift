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
    
    // TODO: test (move to calendar view)
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [])
    private var tsubgoals: FetchedResults<Subgoal>
    
    @AppStorage("isCompletedSubgoalsHidden")
    private var isCompletedSubgoalsHidden: Bool = false
    
    @AppStorage("isFocusesHidden")
    private var isFocusesHidden = false
    
    @AppStorage("focusOfDay")
    private var focusOfDay: String?
    
    @State private var selectedDate = Date()
    
    @State private var isDatePickerPresented = false
    
    @State private var isModalViewPresented = false
    
    @State private var selectedTimeOfDay = Constants.TimesOfDay.getTimeOfDay(
        from: Date())
        
    @State private var selectedSubgoalType: Constants.SubgoalTypes?
    
    private var calendarDays: [Date] {
        let today = Calendar.current.startOfDay(for: Date())
        let allDates = tsubgoals.compactMap {
            return switch $0.type {
            case Constants.SubgoalTypes.task.rawValue: $0.deadline
            case Constants.SubgoalTypes.milestone.rawValue: $0.deadline
            case Constants.SubgoalTypes.habit.rawValue: $0.startDate
            default: nil
            }
        } + [today]
        let uniqueDays = Set(
            allDates.map { Calendar.current.startOfDay(for: $0) })
            .filter { $0 >= today }
        return Array(uniqueDays).sorted()
    }
    
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
            CalendarView()
            Section {
                SubgoalTypeGridView()
            } header: {
                TodaySectionHeaderView()
            }
            Section {
                TimeOfDayPickerView()
                SubgoalSectionView()
            } header: {
                Text(selectedTimeOfDay.rawValue)
                    .font(.custom("Jura", size: 14))
            }
            if !completedSubgoals.isEmpty && !isCompletedSubgoalsHidden {
                Section {
                    ForEach(completedSubgoals) {
                        SubgoalView(subgoal: $0)
                    }
                } header: {
                    Text("Выполнено")
                        .font(.custom("Jura", size: 14))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ToggleHidingCompletedButtonView()
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
        .sheet(isPresented: $isModalViewPresented) {
            InboxView(date: selectedDate)
        }
    }
    
    // MARK: - Private Methods
    private func getSubgoalCount(
        _ subgoalType: Constants.SubgoalTypes
    ) -> Int {
        subgoals
            .filter { $0.type == subgoalType.rawValue }
            .filter { !$0.isCompleted }
            .count
    }
}

// MARK: - Views
private extension MainView {
    
    func CalendarView() -> some View {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.MM"
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EE"
        return LazyHGrid(rows: [GridItem()]) {
            ForEach(calendarDays, id: \.self) { day in
                VStack(spacing: 8) {
                    Text(weekdayFormatter.string(from: day))
                    Text(formatter.string(from: day))
                        .fontWeight(.medium)
                }
                .font(.custom("Jura", size: 17))
                .frame(width: 50, height: 60)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            Calendar.current.isDate(
                                day, inSameDayAs: selectedDate)
                            ? .accent
                            : Color(.secondarySystemBackground))
                }
                .onTapGesture {
                    selectedDate = day
                    subgoals.nsPredicate = SubgoalFilter.predicate(
                        for: day)
                }
            }
            .padding(.top, 16)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
    
    func TodaySectionHeaderView() -> some View {
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
        .font(.custom("Jura", size: 14))
    }
    
    func SubgoalTypeGridView() -> some View {
        VStack {
            if !isFocusesHidden {
                SubgoalTypeSecondaryView(.focus, count: getSubgoalCount(.focus))
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
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
    
    func SubgoalTypePrimaryView(
        _ subgoalType: Constants.SubgoalTypes,
        count: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: subgoalType.imageName)
                    .imageScale(.large)
                    .foregroundStyle(.accent)
                Spacer()
                Text(String(count))
                    .font(.custom("Jura", size: 22))
                    .fontWeight(.semibold)
            }
            Text(subgoalType.plural)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .font(.custom("Jura", size: 17))
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        }
    }
    
    func SubgoalTypeSecondaryView(
        _ subgoalType: Constants.SubgoalTypes,
        count: Int
    ) -> some View {
        VStack {
            HStack {
                Image(systemName: subgoalType.imageName)
                    .imageScale(.large)
                    .foregroundStyle(.accent)
                Text(subgoalType.plural)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(count))
                    .font(.custom("Jura", size: 22))
                    .fontWeight(.semibold)
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
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.secondary.opacity(0.1))
                }
            }
        }
        .font(.custom("Jura", size: 17))
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        }
        .onTapGesture {
            if subgoalType == .inbox {
                isModalViewPresented = true
            } else {
                selectedSubgoalType = subgoalType
            }
        }
    }
    
    func TimeOfDayPickerView() -> some View {
        Picker("", selection: $selectedTimeOfDay) {
            ForEach(Constants.TimesOfDay.allCases.dropLast()) {
                Image(systemName: $0.imageName)
            }
        }
        .pickerStyle(.segmented)
        .listRowInsets(EdgeInsets())
        .padding(.bottom, 10)
    }
    
    func SubgoalSectionView() -> some View {
        Group {
            if uncompletedSubgoals.isEmpty {
                Text("Время дня свободно")
                    .font(.custom("Jura", size: 17))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(uncompletedSubgoals) {
                    SubgoalView(subgoal: $0)
                }
            }
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
