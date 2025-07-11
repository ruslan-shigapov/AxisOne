//
//  JournalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct JournalView: View {
    
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [])
    private var subgoals: FetchedResults<Subgoal>
        
    var body: some View {
        ZStack {
            if subgoals.isEmpty {
                EmptyStateView()
            } else {
                SubgoalListView()
            }
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: HistoryView()) {
                    Image(systemName: "clock")
                }
            }
        }
    }
    
    func EmptyStateView() -> some View {
        Text("На сегодня нет активных подцелей для самоанализа")
            .frame(width: 230)
            .multilineTextAlignment(.center)
            .fontWeight(.medium)
    }
    
    func SubgoalListView() -> some View {
        List {
            Section("Активные подцели") {
                // TODO: отсортировывать по расписанию
                ForEach(subgoals) { subgoal in
                    NavigationLink(
                        destination: AnalysisView(subgoal: subgoal)
                    ) {
                        SubgoalView(subgoal: subgoal)
                            .foregroundStyle(getSubgoalColor(subgoal))
                    }
                }
            }
        }
    }
    
    private func getSubgoalColor(_ subgoal: Subgoal) -> Color {
        let joyEmotions = Constants.Feelings.joy.emotions
        let loveEmotions = Constants.Feelings.love.emotions
        let positiveEmotions = joyEmotions + loveEmotions
        let allEmotions = (subgoal.reflection?.emotions?.components(
            separatedBy: " ") ?? [])
        guard !allEmotions.isEmpty else { return .primary }
        let positiveCount = allEmotions
            .filter { positiveEmotions.contains($0) }
            .count
        return positiveCount > (allEmotions.count / 2) ? .blue : .red
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
