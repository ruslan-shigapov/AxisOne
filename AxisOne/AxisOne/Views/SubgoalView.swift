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
    
    private var lifeAreaColor: Color {
        guard let lifeArea = Constants.LifeAreas(
            rawValue: subgoal.goal?.lifeArea ?? ""
        ) else {
            return .primary
        }
        return lifeArea.color
    }
    
    private var goalTitle: String {
        subgoal.goal?.title ?? ""
    }
    
    var body: some View {
        HStack {
            if subgoal.type != Constants.SubgoalTypes.rule.rawValue {
                CheckmarkImageView()
                    .onTapGesture {
                        withAnimation {
                            toggleCompletion()
                        }
                    }
            }
            TextView()
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
    }
    
    private func CheckmarkImageView() -> some View {
        Image(systemName: subgoal.isCompleted
              ? "checkmark.circle.fill"
              : "circle")
        .font(.system(size: 22))
        .foregroundStyle(.secondary)
    }
    
    private func TextView() -> some View {
        VStack(alignment: .leading) {
            Text(subgoal.title ?? "")
                .lineLimit(2)
                .fontWeight(.medium)
                .foregroundStyle(subgoal.isCompleted
                                 ? .secondary
                                 : lifeAreaColor)
            Text("\(subgoal.type ?? "") • \(subgoal.goal?.lifeArea ?? "")")
                .foregroundStyle(.secondary)
        }
    }
    
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

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
