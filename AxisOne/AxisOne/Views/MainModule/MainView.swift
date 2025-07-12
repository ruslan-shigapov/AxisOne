//
//  MainView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct MainView: View {
    
    // MARK: - Private Properties
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [.init(key: "time", ascending: true)])
    private var subgoals: FetchedResults<Subgoal>
        
    private var currentSubgoals: [Subgoal] {
        subgoals.filter {
            getTimeOfDay(from: $0.time) == getTimeOfDay(from: Date())
        }
    }
        
    @Environment(\.managedObjectContext) private var context
    
    // MARK: - Body
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
    
    // MARK: - Private Methods
    private func getSubgoalColor(_ subgoal: Subgoal) -> Color {
        guard let lifeArea = Constants.LifeAreas(
            rawValue: subgoal.goal?.lifeArea ?? ""
        ) else {
            return .primary
        }
        return lifeArea.color
    }
    
    private func getSubgoalCount(_ subgoalType: Constants.SubgoalTypes) -> Int {
        subgoals.filter { $0.type == subgoalType.rawValue }.count
    }
    
    private func getTimeOfDay(from date: Date?) -> String {
        guard let date else { return "" }
        return switch Calendar.current.component(.hour, from: date) {
        case 5..<12: "Утро"
        case 12..<18: "День"
        case 18...23: "Вечер"
        default: "Ночь"
        }
    }
}

// MARK: - Views
private extension MainView {
    
    func SubgoalTypeGridView() -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]) {
                ForEach(Constants.SubgoalTypes.allCases) {
                    SubgoalTypeView($0, count: getSubgoalCount($0))
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color(.secondarySystemBackground))
    }
    
    func SubgoalTypeView(
        _ subgoalType: Constants.SubgoalTypes,
        count: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: subgoalType.imageName)
                    .imageScale(.large)
                    .foregroundStyle(.blue)
                Spacer()
                Text(String(count))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            Text(subgoalType.rawValue)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground))
        }
    }
    
    func SubgoalListView() -> some View {
        List {
            Section("Сегодня") {
                SubgoalTypeGridView()
            }
            if !currentSubgoals.filter({ !$0.isCompleted }).isEmpty {
                SubgoalListSectionView(
                    "Текущие / \(getTimeOfDay(from: Date()))",
                    for: currentSubgoals.filter { !$0.isCompleted })
            }
            if !currentSubgoals.filter({ $0.isCompleted }).isEmpty {
                SubgoalListSectionView(
                    "Выполнено",
                    for: currentSubgoals.filter { $0.isCompleted })
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
            Text("\(subgoal.type ?? "") • \(subgoal.goal?.lifeArea ?? "")")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
