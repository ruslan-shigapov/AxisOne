//
//  MainView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct MainView: View {
    
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isActive == true"))
    private var subgoals: FetchedResults<Subgoal>
    
    var filteredSubgoals: [Subgoal] {
        subgoals.filter { $0.goal?.isActive == true }
    }
        
    @Environment(\.managedObjectContext) private var context
    
    var body: some View {
        SubgoalListView()
            .toolbar {
                ToolbarItem {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
    }
    
    func SubgoalListView() -> some View {
        List {
            SubgoalListSectionView(
                "Сегодня",
                for: filteredSubgoals.filter { $0.isCompleted == false })
            if !subgoals.filter({ $0.isCompleted == true }).isEmpty {
                SubgoalListSectionView(
                    "Выполнено",
                    for: filteredSubgoals.filter { $0.isCompleted == true })
            }
        }
    }
    
    func SubgoalListSectionView(
        _ title: String,
        for subgoals: [Subgoal]
    ) -> some View {
        Section(title) {
            ForEach(subgoals) { subgoal in
                HStack {
                    CheckmarkImageView(for: subgoal)
                        .onTapGesture {
                            withAnimation {
                                subgoal.isCompleted.toggle()
                                try? context.save()
                            }
                        }
                    TextView(for: subgoal)
                }
            }
        }
    }
    
    func CheckmarkImageView(for subgoal: Subgoal) -> some View {
        Image(systemName: subgoal.isCompleted
              ? "checkmark.circle.fill"
              : "circle")
        .font(.system(size: 22))
        .foregroundStyle(.secondary)
    }

    func TextView(for subgoal: Subgoal) -> some View {
        VStack(alignment: .leading) {
            Text(subgoal.title ?? "")
                .lineLimit(2)
                .fontWeight(.medium)
                .foregroundStyle(subgoal.isCompleted
                                 ? .secondary
                                 : getSubgoalColor(subgoal))
            Text("\(subgoal.type ?? "") / \(subgoal.goal?.lifeArea ?? "")")
                .foregroundStyle(.secondary)
        }
    }

    private func getSubgoalColor(_ subgoal: Subgoal) -> Color {
        guard let lifeArea = Constants.LifeAreas(
            rawValue: subgoal.goal?.lifeArea ?? ""
        ) else {
            return .primary
        }
        return lifeArea.color
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
