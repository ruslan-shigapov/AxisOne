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
    
    private var currentSubgoals: [Subgoal] {
        let subgoalsByExactTime = subgoals.filter {
            let subgoalTime = Constants.TimesOfDay.getTimeOfDay(from: $0.time)
            return subgoalTime.rawValue == selectedTimeOfDay.rawValue
        }
        let subgoalsByTimeOfDay = subgoals.filter {
            $0.timeOfDay == selectedTimeOfDay.rawValue
        }
        let total = subgoalsByExactTime + subgoalsByTimeOfDay
        return total.sorted {
            guard let firstLifeArea = Constants.LifeAreas(
                rawValue: $0.goal?.lifeArea ?? ""),
                  let secondLifeArea = Constants.LifeAreas(
                    rawValue: $1.goal?.lifeArea ?? "")
            else {
                return false
            }
            return firstLifeArea.order < secondLifeArea.order
        }
    }
    
    private var uncompletedSubgoals: [Subgoal] {
        if Calendar.current.isDateInToday(selectedDate) {
            return currentSubgoals.filter { !$0.isCompleted }
        }
        return currentSubgoals
    }
    
    private var completedSubgoals: [Subgoal] {
        currentSubgoals.filter { $0.isCompleted }
    }
    
    // MARK: - Body
    var body: some View {
        List {
            CalendarView(selectedDate: $selectedDate)
                .onChange(of: selectedDate) {
                    subgoals.nsPredicate = SubgoalFilter.predicate(for: $1)
                }
            Section {
                SubgoalTypeGridView()
            } header: {
                HeaderWithToggleView(
                    title: TodaySectionHeaderTitleView(),
                    contentName: "фокус",
                    isContentHidden: $isFocusesHidden)
            }
            Section {
                TimeOfDayPickerView()
                SubgoalSectionView()
            } header: {
                HeaderView(text: selectedTimeOfDay.rawValue)
            }
            if !completedSubgoals.isEmpty,
               !isCompletedSubgoalsHidden,
               Calendar.current.isDateInToday(selectedDate) {
                Section {
                    ForEach(completedSubgoals) {
                        SubgoalView(
                            subgoal: $0,
                            isToday: Calendar.current.isDateInToday(
                                selectedDate))
                    }
                } header: {
                    HeaderView(text: "Выполнено")
                }
            }
        }
        .toolbar {
            if Calendar.current.isDateInToday(selectedDate) {
                ToolbarItem {
                    ToolbarButtonView(
                        type: .toggleCompletedVisibility,
                        isCompletedHidden: $isCompletedSubgoalsHidden
                    )
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
            .filter {
                !$0.isCompleted || !Calendar.current.isDateInToday(selectedDate)
            }
            .count
    }
}

// MARK: - Views
private extension MainView {
    
    func TodaySectionHeaderTitleView() -> some View {
        if Calendar.current.isDateInToday(selectedDate) {
            Text("Сегодня")
        } else {
            Text(selectedDate.formatted(date: .long, time: .omitted))
        }
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
                EmptyRowTextView(text: "Время дня свободно")
            } else {
                ForEach(uncompletedSubgoals) {
                    SubgoalView(
                        subgoal: $0,
                        isToday: Calendar.current.isDateInToday(selectedDate))
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
