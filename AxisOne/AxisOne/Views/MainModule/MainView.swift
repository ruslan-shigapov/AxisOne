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
    
    @AppStorage("isCalendarExpanded")
    private var isCalendarExpanded: Bool = true
    
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
        VStack(spacing: 0) {
            NavigationBarView()
            List {
                SubgoalListSectionsView(
                    date: selectedDate,
                    subgoals: subgoals,
                    title: selectedTimeOfDay.rawValue,
                    emptyRowText: "Время дня свободно",
                    isCompletedHidden: isCompletedSubgoalsHidden)
            }
        }
        .sheet(item: $selectedSubgoalType) {
            SubgoalTypeView(type: $0, date: selectedDate)
        }
    }
    
    private func format(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            "Сегодня"
        } else if Calendar.current.isDateInTomorrow(date) {
            "Завтра"
        } else {
            date.formatted(date: .numeric, time: .omitted)
        }
    }
}

// MARK: - Views
private extension MainView {
    
    func NavigationBarView() -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 16) {
                Spacer()
                if Calendar.current.isDateInToday(selectedDate) {
                    Button {
                        isCompletedSubgoalsHidden.toggle()
                    } label: {
                        NavBarButtonImageView(
                            type: .toggleVisibility(
                                isActive: isCompletedSubgoalsHidden))
                    }
                }
                NavigationLink(destination: SettingsView()) {
                    NavBarButtonImageView(type: .settings)
                }
            }
            .font(.system(size: 22))
            .padding(.horizontal)
            HStack(alignment: .bottom) {
                Text("Главное")
                    .font(.custom("Jura-Bold", size: 34))
                if !isCalendarExpanded {
                    Text(format(selectedDate))
                        .font(.custom("Jura-Bold", size: 20))
                        .foregroundStyle(.secondary)
                        .offset(y: -4)
                }
                Spacer()
                Button {
                    withAnimation {
                        isCalendarExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isCalendarExpanded
                          ? "chevron.down"
                          : "chevron.right")
                }
                .foregroundStyle(.primary)
                .offset(y: -10)
            }
            .padding(.horizontal)
            if isCalendarExpanded {
                CalendarScrollView(selectedDate: $selectedDate)
                    .padding(.top, 4)
                    .onChange(of: selectedDate) {
                        subgoals.nsPredicate = SubgoalFilter.predicate(
                            for: $1,
                            timeOfDay: selectedTimeOfDay,
                            types: [.task, .habit, .milestone, .inbox])
                    }
            }
            VStack(spacing: 22) {
                SubgoalTypesView(
                    selectedType: $selectedSubgoalType,
                    date: selectedDate)
                TimeOfDayPickerView(selectedTimeOfDay: $selectedTimeOfDay) 
                    .onChange(of: selectedTimeOfDay) {
                        subgoals.nsPredicate = SubgoalFilter.predicate(
                            for: selectedDate,
                            timeOfDay: $1,
                            types: [.task, .habit, .milestone, .inbox])
                    }
            }
            .padding(.top, 10)
            .padding(.horizontal)
            .padding(.bottom, -5)
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("Silver"))
//                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .offset(y: -110)
        }
        .padding(.top, -5)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
