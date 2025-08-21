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

    private var lifeArea: Constants.LifeAreas? {
        Constants.LifeAreas(rawValue: subgoal.goal?.lifeArea ?? "")
    }
    
    private var timeOfDay: Constants.TimesOfDay {
        if let time = subgoal.time {
            return Constants.TimesOfDay.getTimeOfDay(from: time)
        } else if let timeOfDay = subgoal.timeOfDay {
            return Constants.TimesOfDay(rawValue: timeOfDay) ?? .unknown
        } else {
            return .unknown
        }
    }
    
    private var isMissed: Bool {
        guard !subgoal.isCompleted, isToday else { return false }
        return timeOfDay.order < Constants.TimesOfDay.getTimeOfDay(
            from: .now).order
    }

    // MARK: - Public Properties
    @ObservedObject var subgoal: Subgoal
    let isToday: Bool
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if subgoal.type != Constants.SubgoalTypes.inbox.rawValue {
                    CapsuleView(
                        color: subgoal.isActive
                        ? lifeArea?.color ?? .clear
                        : .clear,
                        title: subgoal.goal?.lifeArea)
                }
                CapsuleView(color: .clear, title: subgoal.type)
                if let time = subgoal.time {
                    ExactTimeView(time)
                }
            }
            HStack(spacing: 12) {
                if let subgoalType = Constants.SubgoalTypes(
                    rawValue: subgoal.type ?? ""),
                   subgoalType != Constants.SubgoalTypes.focus {
                    CheckmarkImageView(
                        isCompleted: isToday
                        ? subgoal.isCompleted
                        : false)
                    .onTapGesture {
                        if isToday {
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
                ListRowTextView(
                    primaryText: subgoal.title,
                    secondaryText: subgoal.goal?.title,
                    isActive: isMissed,
                    isCompleted: isToday ? subgoal.isCompleted : false)
            }
        }
        .listRowInsets(EdgeInsets())
        .padding(12)
        .onTapGesture {
            isModalViewPresented = true
        }
        .swipeActions {
            SwipeActionButtonView(type: .reschedule) {
                isConfirmationDialogPresented = true
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
                isModalPresentation: true)
        }
        .confirmationDialog(
            "Перенести на...",
            isPresented: $isConfirmationDialogPresented,
            titleVisibility: .visible
        ) {
            ForEach(Constants.TimesOfDay.allCases.dropLast()) { value in
                Button(value.rawValue) {
                    if subgoal.deadline == nil {
                        subgoal.deadline = .now
                    }
                    do {
                        try subgoalService.reschedule(subgoal, to: value)
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
            Text("Выполнение привычек доступно только сегодня.")
        }
    }
    
    // MARK: - Private Methods
    private func toggleCompletion() {
        do {
            if subgoal.type == Constants.SubgoalTypes.inbox.rawValue,
               subgoal.isCompleted == false,
               subgoal.deadline == nil {
                try subgoalService.completeNow(subgoal)
            } else {
                try subgoalService.toggleComplete(of: subgoal)
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
            .background(color.verticalGradient().clipShape(Capsule()))
            .overlay(Capsule().stroke(.primary, lineWidth: 0.4))
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
