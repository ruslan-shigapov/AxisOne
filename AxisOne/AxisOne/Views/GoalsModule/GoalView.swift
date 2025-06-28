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
                    complete()
                }
            TitleView()
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
    private func complete() {
        goal.isCompleted.toggle()
        goal.isActive = false
        try? context.save()
    }
}

// MARK: - Views
private extension GoalView {
    
    func CheckmarkImageView() -> some View {
        Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 22))
            .foregroundStyle(.secondary)
    }
    
    func TitleView() -> some View {
        VStack(alignment: .leading) {
            Text(goal.title ?? "")
                .lineLimit(2)
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
        .background()
    }
    
    func ToggleActivationButtonView() -> some View {
        Button {
            goal.isActive.toggle()
            try? context.save()
        } label: {
            Image(systemName: goal.isActive ? "bookmark.slash" : "bookmark")
        }
        .tint(goal.isActive ? .gray : activationColor)
    }
    
    func DeleteButtonView() -> some View {
        Button(role: .destructive) {
            context.delete(goal)
            try? context.save()
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
