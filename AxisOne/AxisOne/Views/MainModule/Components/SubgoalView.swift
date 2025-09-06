//
//  SubgoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct SubgoalView: View {
    
    // MARK: - Private Properties
    @Environment(\.subgoalService) private var subgoalService
    
    @State private var isModalViewPresented = false
    @State private var isConfirmationDialogPresented = false
    @State private var isConfirmationAlertPresented = false
    @State private var isErrorAlertPresented = false

    private var lifeArea: LifeAreas? {
        LifeAreas(rawValue: subgoal.goal?.lifeArea ?? "")
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(currentDate)
    }
    
    private var isYesterday: Bool {
        Calendar.current.isDateInYesterday(currentDate)
    }
    
    private var timeOfDay: TimesOfDay {
        return if let timeOfDay = TimesOfDay.getComparableValue(
            from: currentDate,
            for: subgoal
        ) {
            timeOfDay
        } else if let time = subgoal.time {
            TimesOfDay.getValue(from: time)
        } else {
            .unknown
        }
    }
    
    private var isMissed: Bool {
        guard subgoal.deadline != nil else { return false }
        return if isYesterday {
            subgoal.wasCompleted ? false : true
        } else if isToday {
            subgoal.isCompleted
            ? false
            : timeOfDay.order < TimesOfDay.getValue(
                from: .now).order
        } else {
            false
        }
    }
    
    private var isCompleted: Bool {
        return if currentDate.isInRecentDates {
            if isYesterday,
               subgoal.type == SubgoalTypes.habit.rawValue {
                subgoal.wasCompleted
            } else {
                subgoal.isCompleted
            }
        } else {
            false
        }
    }

    // MARK: - Public Properties
    @ObservedObject var subgoal: Subgoal
    let currentDate: Date
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if let lifeArea {
                    CapsuleView(
                        color: subgoal.isActive ? lifeArea.color : .clear,
                        title: subgoal.goal?.lifeArea)
                }
                CapsuleView(color: .clear, title: subgoal.type)
                if let time = subgoal.time,
                   !(isToday && subgoal.todayMoved != nil) &&
                    !(isYesterday && subgoal.yesterdayMoved != nil) {
                    ExactTimeView(time)
                }
            }
            HStack(spacing: 12) {
                if let subgoalType = SubgoalTypes(
                    rawValue: subgoal.type ?? ""),
                   subgoalType != SubgoalTypes.focus {
                    CheckmarkImageView(isCompleted: isCompleted)
                    .onTapGesture {
                        if currentDate.isInRecentDates {
                            withAnimation(.snappy) {
                                toggleCompletion()
                            }
                        } else {
                            if subgoalType == .habit {
                                isErrorAlertPresented = true
                            } else {
                                isConfirmationAlertPresented = true
                            }
                        }
                    }
                }
                RowTextView(
                    primaryText: subgoal.title ?? "",
                    secondaryText: subgoal.goal?.title,
                    isActive: isMissed,
                    isCompleted: isCompleted)
            }
        }
        .listRowInsets(EdgeInsets())
        .padding(12)
        .contentShape(.rect)
        .onTapGesture {
            isModalViewPresented = true
        }
        .swipeActions(allowsFullSwipe: currentDate.isInRecentDates) {
            if subgoal.type != SubgoalTypes.focus.rawValue,
               currentDate.isInRecentDates &&
                !(subgoal.type == SubgoalTypes.inbox.rawValue &&
                subgoal.deadline == nil) {
                SwipeActionButtonView(type: .reschedule) {
                    isConfirmationDialogPresented = true
                }
            }
            SwipeActionButtonView(type: .delete) {
                do {
                    try subgoalService.delete(subgoal)
                } catch {
                    print(error)
                }
            }
        }
        .sheet(isPresented: $isModalViewPresented) {
            DetailSubgoalView(
                lifeArea: lifeArea,
                subgoal: subgoal,
                subgoals: .constant([]),
                isModified: .constant(false),
                isModalPresentation: $isModalViewPresented)
        }
        .confirmationDialog(
            "Перенести \(isToday ? "сегодняшнюю" : "вчерашнюю") подцель на...",
            isPresented: $isConfirmationDialogPresented,
            titleVisibility: .visible
        ) {
            ForEach(TimesOfDay.allCases.dropLast()) { value in
                Button(value.rawValue) {
                    do {
                        try subgoalService.reschedule(
                            subgoal,
                            to: value,
                            isToday: isToday)
                    } catch {
                        print(error)
                    }
                }
                .disabled(timeOfDay == value)
            }
            Button("Отмена", role: .cancel) {}
        }
        .alert(
            "Вы уверены?",
            isPresented: $isConfirmationAlertPresented,
            actions: {
                Button("Да") {
                    withAnimation(.snappy) {
                        do {
                            try subgoalService.completeNow(subgoal)
                        } catch {
                            print(error)
                        }
                    }
                }
                Button("Нет", role: .cancel) {}
            }
        ) {
            Text("Подцель будет выполнена сегодняшним числом.")
        }
        .alert(
            "Внимание",
            isPresented: $isErrorAlertPresented, actions: {}
        ) {
            Text("Выполнение привычек доступно только для сегодняшних или вчерашних.")
        }
    }
    
    // MARK: - Private Methods
    private func toggleCompletion() {
        do {
            if subgoal.type == SubgoalTypes.inbox.rawValue,
               subgoal.isCompleted == false,
               subgoal.deadline == nil {
                try subgoalService.completeNow(subgoal)
            } else {
                try subgoalService.toggleComplete(
                    of: subgoal,
                    isYesterday: isYesterday)
            }
        } catch {
            print(error)
        }
    }
}

// MARK: - Views
private extension SubgoalView {
    
    func CapsuleView(color: Color, title: String?) -> some View {
        Text(title ?? "")
            .font(Constants.Fonts.juraFootnote)
            .frame(width: 90, height: 24)
            .background {
                Capsule().fill(color.gradient)
            }
            .overlay(Capsule().stroke(.primary, lineWidth: 0.3))
    }
    
    func ExactTimeView(_ time: Date) -> some View {
        HStack {
            Spacer()
            Text(time.formatted(date: .omitted, time: .shortened))
                .font(Constants.Fonts.juraBody)
            Image(systemName: "bell.fill")
                .imageScale(.small)
        }
        .foregroundStyle(subgoal.isCompleted ? .secondary : .primary)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
