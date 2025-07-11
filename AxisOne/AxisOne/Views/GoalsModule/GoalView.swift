//
//  GoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct GoalView: View {
    
    // MARK: - Private Properties
    @State private var isModalViewPresented = false
    
    @Environment(\.managedObjectContext) private var context
    
    private var activationColor: Color {
        Constants.LifeAreas(
            rawValue: goal.lifeArea ?? "")?.color ?? .secondary
    }
    
    // MARK: - Public Properties
    @ObservedObject var goal: Goal
    
    // MARK: - Body
    var body: some View {
        HStack {
            CheckmarkImageView()
                .onTapGesture {
                    withAnimation {
                        toggleCompletion()
                    }
                }
            TextView()
                .onTapGesture {
                    isModalViewPresented = true
                }
        }
        .swipeActions(allowsFullSwipe: true) {
            if !goal.isCompleted {
                ToggleActivationButtonView()
            }
            DeleteButtonView()
        }
        .sheet(isPresented: $isModalViewPresented) {
            DetailGoalView(goal: goal)
        }
    }
    
    // MARK: - Private Methods
    private func toggleCompletion() {
        goal.isCompleted.toggle()
        if goal.isCompleted {
            goal.isActive = false
            goal.subgoals?.forEach {
                ($0 as? Subgoal)?.isActive = false
            }
            goal.order = getOrder()
        }
        try? context.save()
    }
    
    private func getOrder() -> Int16 {
        guard let lifeArea = goal.lifeArea else { return 0 }
        let fetchRequest = Goal.fetchRequest()
        fetchRequest.predicate = .init(
            format: "lifeArea == %@",
            argumentArray: [lifeArea])
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: true)]
        let lastGoal = try? context.fetch(fetchRequest).last
        return (lastGoal?.order ?? 0) + 1
    }
}

// MARK: - Views
private extension GoalView {
    
    func CheckmarkImageView() -> some View {
        Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 22))
            .foregroundStyle(.secondary)
    }
    
    func TextView() -> some View {
        VStack(alignment: .leading) {
            Text(goal.title ?? "")
                .lineLimit(2)
                .fontWeight(.medium)
                .foregroundStyle(goal.isActive
                                 ? activationColor
                                 : goal.isCompleted ? .secondary : .primary)
            if let notes = goal.notes, !notes.isEmpty {
                Text(notes)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
    
    func ToggleActivationButtonView() -> some View {
        Button {
            withAnimation {
                goal.isActive.toggle()
                goal.subgoals?.forEach {
                    ($0 as? Subgoal)?.isActive.toggle()
                }
                try? context.save()
            }
        } label: {
            Image(systemName: goal.isActive ? "bookmark.slash" : "bookmark")
        }
        .tint(goal.isActive ? .gray : activationColor)
    }
    
    func DeleteButtonView() -> some View {
        Button(role: .destructive) {
            withAnimation {
                context.delete(goal)
                try? context.save()
            }
        } label: {
            Image(systemName: "trash")
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
