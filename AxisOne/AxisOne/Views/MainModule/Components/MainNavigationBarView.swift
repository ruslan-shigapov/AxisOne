//
//  MainNavigationBarView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 20.08.2025.
//

import SwiftUI

struct MainNavigationBarView: View {
    
    // MARK: - Private Properties
    @AppStorage("isCalendarExpanded")
    private var isCalendarExpanded: Bool = true
        
    // MARK: - Public Properties
    @Binding var selectedDate: Date
    @Binding var isCompletedSubgoalsHidden: Bool
    @Binding var selectedTimeOfDay: TimesOfDay
    let subgoals: FetchedResults<Subgoal>
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            ToolbarView()
            TitleView()
            if isCalendarExpanded {
                CalendarScrollView(selectedDate: $selectedDate)
                    .onChange(of: selectedDate) {
                        subgoals.nsPredicate = SubgoalFilter.predicate(
                            for: $1,
                            timeOfDay: selectedTimeOfDay,
                            types: [.task, .habit, .milestone, .inbox])
                    }
            }
            VStack(spacing: 24) {
                SubgoalTypesView(date: selectedDate)
                TimeOfDayPickerView(selectedTimeOfDay: $selectedTimeOfDay)
                    .onChange(of: selectedTimeOfDay) {
                        subgoals.nsPredicate = SubgoalFilter.predicate(
                            for: selectedDate,
                            timeOfDay: $1,
                            types: [.task, .habit, .milestone, .inbox])
                    }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .offset(y: -100)
                .fillWithShadow()
        }
    }
    
    // MARK: - Private Methods
    private func format(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            Constants.Texts.today
        } else if Calendar.current.isDateInYesterday(date) {
            Constants.Texts.yesterday
        } else if Calendar.current.isDateInTomorrow(date) {
            Constants.Texts.tomorrow
        } else {
            date.formatted(date: .numeric, time: .omitted)
        }
    }
}

// MARK: - Views
private extension MainNavigationBarView {
    
    func ToolbarView() -> some View {
        HStack(spacing: 20) {
            Spacer()
            if selectedDate.isInRecentDates {
                Button {
                    isCompletedSubgoalsHidden.toggle()
                } label: {
                    ToolbarButtonImageView(
                        type: .toggleVisibility(
                            isActive: isCompletedSubgoalsHidden))
                }
            }
            NavigationLink(destination: SettingsView()) {
                ToolbarButtonImageView(type: .settings)
            }
        }
        .imageScale(.large)
        .padding(.horizontal)
        .padding(.top, 3)
    }
    
    func TitleView() -> some View {
        HStack {
            Text("Главное")
                .font(Constants.Fonts.juraLargeTitle)
            if !isCalendarExpanded {
                Text(format(selectedDate))
                    .font(Constants.Fonts.juraHeadline)
                    .foregroundStyle(.secondary)
                    .offset(y: 5)
            }
            Spacer()
            Button {
                withAnimation(.snappy) {
                    isCalendarExpanded.toggle()
                }
            } label: {
                Image(
                    systemName: isCalendarExpanded
                    ? "chevron.down"
                    : "chevron.right")
            }
            .foregroundStyle(.primary)
            .fontWeight(.medium)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
