//
//  SubgoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct SubgoalView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var subgoal: Subgoal
    
    var body: some View {
        HStack {
            if subgoal.type != Constants.SubgoalTypes.rule.rawValue {
                CheckmarkImageView()
                    .onTapGesture {
                        withAnimation {
                            subgoal.isCompleted.toggle()
                            try? context.save()
                        }
                    }
            }
            TextView()
                .onTapGesture {
//                    isModalViewPresented = true
                }
        }
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive) {
                withAnimation {
                    context.delete(subgoal)
                    try? context.save()
                }
            } label: {
                Image(systemName: "trash")
            }
        }
//        .sheet(isPresented: $isModalViewPresented) {
//            DetailGoalView(goal: goal)
//        }
    }
    
    private func getSubgoalColor(_ subgoal: Subgoal) -> Color {
        guard let lifeArea = Constants.LifeAreas(
            rawValue: subgoal.goal?.lifeArea ?? ""
        ) else {
            return .primary
        }
        return lifeArea.color
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
                .lineLimit(2)
                .fontWeight(.medium)
                .foregroundStyle(subgoal.isCompleted
                                 ? .secondary
                                 : getSubgoalColor(subgoal))
            Text("\(subgoal.type ?? "") • \(subgoal.goal?.lifeArea ?? "")")
                .foregroundStyle(.secondary)
        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .contentShape(Rectangle())
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
