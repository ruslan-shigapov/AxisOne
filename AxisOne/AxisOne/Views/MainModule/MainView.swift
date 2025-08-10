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
        sortDescriptors: [],
        predicate: SubgoalFilter.predicate(
            for: .now,
            timeOfDay: Constants.TimesOfDay.getTimeOfDay(from: .now),
            types: [.task, .habit, .milestone, .inbox]))
    private var subgoals: FetchedResults<Subgoal>
    
    @AppStorage("isCompletedSubgoalsHidden")
    private var isCompletedSubgoalsHidden: Bool = false
    
    @AppStorage("isFocusesHidden")
    private var isFocusesHidden = false
    
    @AppStorage("focusOfDay")
    private var focusOfDay: String?
    
    @State private var selectedDate = Date()
    
    @State private var isDatePickerPresented = false
        
    @State private var selectedTimeOfDay = Constants.TimesOfDay.getTimeOfDay(
        from: .now)
        
    @State private var selectedSubgoalType: Constants.SubgoalTypes?
        
    private var uncompletedSubgoals: [Subgoal] {
        if Calendar.current.isDateInToday(selectedDate) {
            return subgoals.filter { !$0.isCompleted }
        }
        return Array(subgoals)
    }
    
    private var completedSubgoals: [Subgoal] {
        subgoals.filter { $0.isCompleted }
    }
    
    // MARK: - Body
    var body: some View {
        List {
            CalendarScrollView(selectedDate: $selectedDate)
                .onChange(of: selectedDate) {
                    subgoals.nsPredicate = SubgoalFilter.predicate(
                        for: $1,
                        timeOfDay: selectedTimeOfDay,
                        types: [.task, .habit, .milestone, .inbox])
                }
            SubgoalTypeSectionView(
                date: selectedDate,
                selectedSubgoalType: $selectedSubgoalType)
            Section {
                TimeOfDayPickerView()
                    .onChange(of: selectedTimeOfDay) {
                        subgoals.nsPredicate = SubgoalFilter.predicate(
                            for: selectedDate,
                            timeOfDay: $1,
                            types: [.task, .habit, .milestone, .inbox])
                    }
                SubgoalListView(
                    subgoals: uncompletedSubgoals,
                    emptyRowText: "Время дня свободно",
                    date: selectedDate)
            } header: {
                HeaderView(text: selectedTimeOfDay.rawValue)
            }
            if !completedSubgoals.isEmpty,
               !isCompletedSubgoalsHidden,
               Calendar.current.isDateInToday(selectedDate) {
                SubgoalListSectionView(
                    subgoals: completedSubgoals,
                    date: selectedDate,
                    headerTitle: "Выполнено")
            }
        }
        .toolbar {
            if Calendar.current.isDateInToday(selectedDate) {
                ToolbarItem {
                    NavBarImageButtonView(
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
    }
}

// MARK: - Views
private extension MainView {
    
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
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
