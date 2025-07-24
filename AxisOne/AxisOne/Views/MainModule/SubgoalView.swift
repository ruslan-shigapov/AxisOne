//
//  SubgoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct SubgoalView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @State private var isModalViewPresented = false

    private var lifeArea: Constants.LifeAreas {
        Constants.LifeAreas(rawValue: subgoal.goal?.lifeArea ?? "") ?? .health
    }
    
    private var goalTitle: String {
        subgoal.goal?.title ?? ""
    }
    
    @ObservedObject var subgoal: Subgoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                LifeAreaCapsuleView()
                TypeCapsuleView()
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
        .sheet(isPresented: $isModalViewPresented) {
            DetailSubgoalView(
                lifeArea: lifeArea,
                subgoal: subgoal,
                subgoals: .constant([]),
                isModified: .constant(false),
                isModalPresentation: true)
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

private extension SubgoalView {
    
    func TypeCapsuleView() -> some View {
        Capsule()
            .fill(.secondary)
            .frame(width: 90, height: 22)
            .overlay(
                Text(subgoal.type ?? "")
                    .font(.footnote)
            )
    }
    
    func LifeAreaCapsuleView() -> some View {
        Capsule()
            .fill(lifeArea.color)
            .frame(width: 100, height: 22)
            .overlay(
                Text(subgoal.goal?.lifeArea ?? "")
                    .font(.footnote)
            )
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
                .foregroundStyle(subgoal.isCompleted ? .secondary : .primary)
            Text("Цель: \(subgoal.goal?.title ?? "")")
                .lineLimit(1)
                .fontWeight(.light)
                .foregroundStyle(.secondary)
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
