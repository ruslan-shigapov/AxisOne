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
        guard !subgoal.isCompleted else { return false }
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
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if subgoal.type != Constants.SubgoalTypes.inbox.rawValue {
                    CapsuleView(
                        color: lifeArea.color,
                        title: subgoal.goal?.lifeArea)
                }
                CapsuleView(color: .clear, title: subgoal.type)
                if let time = subgoal.time {
                    Spacer()
                    Text(time.formatted(date: .omitted, time: .shortened))
                    Image(systemName: "bell")
                }
            }
            HStack {
                if subgoal.type != Constants.SubgoalTypes.focus.rawValue {
                    CheckmarkImageView()
                        .onTapGesture {
                            withAnimation {
                                toggleCompletion()
                            }
                        }
                }
                TextView()
                    .onTapGesture {
                        isModalViewPresented = true
                    }
            }
        }
        .padding(12)
        .listRowInsets(EdgeInsets())
        .swipeActions {
            Button {
                isConfirmationDialogPresented = true
            } label: {
                Image(systemName: "move.3d")
            }
            .tint(.accent)
            Button(role: .destructive) {
                withAnimation {
                    context.delete(subgoal)
                    try? context.save()
                }
            } label: {
                Image(systemName: "trash")
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
            isPresented: $isConfirmationDialogPresented, titleVisibility: .visible
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
            .frame(width: 96, height: 24)
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
    
    func CheckmarkImageView() -> some View {
        Image(systemName: subgoal.isCompleted
              ? "checkmark.circle.fill"
              : "circle")
        .font(.system(size: 22))
        .foregroundStyle(.secondary)
    }
    
    func TextView() -> some View {
        VStack(alignment: .leading) {
            Text(subgoal.title ?? "")
                .font(.custom("Jura", size: 17))
                .lineLimit(2)
                .fontWeight(isMissed ? .regular : .medium)
                .foregroundStyle(subgoal.isCompleted
                                 ? .secondary
                                 : isMissed ? Color.red : .primary)
            if subgoal.type != Constants.SubgoalTypes.inbox.rawValue {
                Text("Цель: \(subgoal.goal?.title ?? "")")
                    .font(.custom("Jura", size: 17))
                    .lineLimit(1)
                    .fontWeight(.light)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
