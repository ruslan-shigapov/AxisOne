//
//  SubgoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct SubgoalView: View {
    
    // MARK: - Private Properties
    @Environment(\.managedObjectContext) private var context
    
    @State private var isModalViewPresented = false
    
    @State private var isConfirmationDialogPresented = false
    
    @State private var isConfirmationAlertPresented = false
    @State private var isErrorAlertPresented = false

    private var lifeArea: Constants.LifeAreas {
        Constants.LifeAreas(rawValue: subgoal.goal?.lifeArea ?? "") ?? .health
    }
    
    private var goalTitle: String {
        subgoal.goal?.title ?? ""
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
        guard subgoal.type != Constants.SubgoalTypes.focus.rawValue else {
            return false
        }
        guard !subgoal.isCompleted, isToday else { return false }
        if let deadline = subgoal.deadline {
            guard Calendar.current.isDate(deadline, inSameDayAs: Date()) else {
                return false
            }
        }
        guard timeOfDay != .unknown else { return false }
        return timeOfDay.order < Constants.TimesOfDay.getTimeOfDay(
            from: Date()).order
    }

    // MARK: - Public Properties
    @ObservedObject var subgoal: Subgoal
    let isToday: Bool
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if subgoal.type != Constants.SubgoalTypes.inbox.rawValue {
                    CapsuleView(
                        color: subgoal.isActive ? lifeArea.color : .clear,
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
                    CheckmarkImageView(isCompleted: isToday
                                       ? $subgoal.isCompleted
                                       : .constant(false))
                        .onTapGesture {
                            if isToday {
                                withAnimation {
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
                    isActive: .constant(isMissed),
                    isCompleted: isToday
                    ? $subgoal.isCompleted
                    : .constant(false))
                .onTapGesture {
                    isModalViewPresented = true
                }
            }
        }
        .padding(12)
        .listRowInsets(EdgeInsets())
        .swipeActions {
            SwipeActionButtonView(type: .move) {
                isConfirmationDialogPresented = true
            }
            SwipeActionButtonView(type: .delete) {
                context.delete(subgoal)
                try? context.save()
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
                    subgoal.timeOfDay = value.rawValue
                    try? context.save()
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
                    subgoal.deadline = Date()
                    if let _ = subgoal.time {
                        subgoal.time = Date()
                    } else {
                        subgoal.timeOfDay = Constants.TimesOfDay.getTimeOfDay(
                            from: Date()).rawValue
                    }
                    subgoal.isCompleted = true
                    try? context.save()
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
        subgoal.isCompleted.toggle()
        subgoal.order = getOrder()
        try? context.save()
    }
    
    private func getOrder() -> Int16 {
        let fetchRequest = Subgoal.fetchRequest()
        fetchRequest.predicate = .init(
            format: "goal.title == %@",
            argumentArray: [goalTitle])
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: true)]
        let lastSubgoal = try? context.fetch(fetchRequest).last
        return (lastSubgoal?.order ?? 0) + 1
    }
}

// MARK: - Views
private extension SubgoalView {
    
    func CapsuleView(color: Color, title: String?) -> some View {
        Text(title ?? "")
            .font(.custom("Jura", size: 13))
            .frame(width: 90, height: 24)
            .background(
                Capsule().fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                color.opacity(0.45),
                                color
                            ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
            )
            .overlay(Capsule().stroke(.primary, lineWidth: 1))
    }
    
    func ExactTimeView(_ time: Date) -> some View {
        HStack {
            Spacer()
            Text(time.formatted(date: .omitted, time: .shortened))
                .font(.custom("Jura", size: 17))
            Image(systemName: "bell.fill")
                .imageScale(.small)
        }
        .foregroundStyle(subgoal.isCompleted
                         ? .secondary
                         : .primary)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
