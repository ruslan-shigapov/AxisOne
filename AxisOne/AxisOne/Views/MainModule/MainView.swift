//
//  MainView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct MainView: View {
    
    // MARK: - Private Properties
    @FetchRequest(entity: Subgoal.entity(), sortDescriptors: [])
    private var subgoals: FetchedResults<Subgoal>
        
    private var currentSubgoals: [Subgoal] {
        let subgoalsByExactTime = subgoals.filter {
            getTimeOfDay(from: $0.time) == getTimeOfDay(from: Date())
        }
        let subgoalsByTimeOfDay = subgoals.filter {
            $0.timeOfDay == getTimeOfDay(from: Date()).rawValue
        }
        return subgoalsByExactTime + subgoalsByTimeOfDay
    }
    
    @State private var selectedSubgoalType: Constants.SubgoalTypes?
    
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
            .sheet(item: $selectedSubgoalType) {
                SubgoalTypeView(type: $0)
            }
    }
    
    // MARK: - Private Methods
    private func getSubgoalCount(_ subgoalType: Constants.SubgoalTypes) -> Int {
        subgoals.filter { $0.type == subgoalType.rawValue }.count
    }
    
    private func getTimeOfDay(from date: Date?) -> Constants.TimesOfDay {
        guard let date else { return .unknown }
        return switch Calendar.current.component(.hour, from: date) {
        case 5..<12: .morning
        case 12..<18: .afternoon
        case 18...23: .evening
        default: .night
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
                ForEach(Constants.SubgoalTypes.allCases) { type in
                    SubgoalTypeCardView(type, count: getSubgoalCount(type))
                        .onTapGesture {
                            if getSubgoalCount(type) > 0 {
                                selectedSubgoalType = type
                            }
                        }
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color(.secondarySystemBackground))
    }
    
    func SubgoalTypeCardView(
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
            Text(subgoalType.plural)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        }
    }
    
    func SubgoalListView() -> some View {
        List {
            Section("Сегодня") {
                SubgoalTypeGridView()
            }
            let uncompletedSubgoals = currentSubgoals.filter { !$0.isCompleted }
            if !uncompletedSubgoals.isEmpty {
                Section(getTimeOfDay(from: Date()).rawValue) {
                    ForEach(uncompletedSubgoals) {
                        SubgoalView(subgoal: $0)
                    }
                }
            }
            let completedSubgoals = currentSubgoals.filter { $0.isCompleted }
            if !completedSubgoals.isEmpty {
                Section("Выполнено") {
                    ForEach(completedSubgoals) {
                        SubgoalView(subgoal: $0)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
