//
//  JournalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct JournalView: View {
    
    // MARK: - Private Properties
    @FetchRequest(
        entity: Subgoal.entity(),
        sortDescriptors: [.init(key: "time", ascending: true)],
        predicate: SubgoalFilter.predicate(
            for: .now,
            types: [.task, .habit, .milestone, .inbox]))
    private var subgoals: FetchedResults<Subgoal>
    
    @FetchRequest(
        entity: Reflection.entity(),
        sortDescriptors: [],
        predicate: ReflectionFilter.predicate(for: .now))
    private var reflections: FetchedResults<Reflection>
    
    @State private var isModalPresented = false
    
    private var groupedSubgoals: [Constants.TimesOfDay: [Subgoal]] {
        Dictionary(grouping: subgoals) {
            if let exactTime = $0.time {
                return Constants.TimesOfDay.getTimeOfDay(from: exactTime)
            } else if let timeOfDay = $0.timeOfDay {
                return Constants.TimesOfDay(rawValue: timeOfDay) ?? .unknown
            }
            return .unknown
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if groupedSubgoals.isEmpty {
                EmptyStateView(
                    primaryText: "На сегодня нет активных подцелей для самоанализа")
            } else {
                List {
                    TimeOfDaySectionView()
                    SummarySectionView()
                }
            }
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: HistoryView()) {
                    NavBarButtonImageView(type: .history)
                }
            }
        }
        .sheet(isPresented: $isModalPresented) {
            SummaryView(date: Date())
        }
    }
    
    private func getGroupedValues() -> [(Constants.LifeAreas, String, Double)] {
        let reflectedSubgoals = reflections
            .compactMap { $0.reactions as? Set<Reaction> }
            .flatMap { $0 }
            .compactMap { $0.subgoal }
        return Constants.LifeAreas.allCases.map { lifeArea in
            let matching = reflectedSubgoals.filter {
                let subgoalLifeArea = Constants.LifeAreas(
                    rawValue: $0.goal?.lifeArea ?? "")
                return subgoalLifeArea == lifeArea
            }
            let allSubgoals = subgoals.filter {
                $0.goal?.lifeArea ?? "" == lifeArea.rawValue
            }.count
            let completed = matching.filter(\.isCompleted).count
            let progress = allSubgoals > 0
            ? Double(completed) / Double(allSubgoals)
            : 0
            return (lifeArea, "\(completed)/\(allSubgoals)", progress)
        }
    }
}

// MARK: - Views
private extension JournalView {
    
    func TimeOfDaySectionView() -> some View {
        Section {
            ForEach(
                Constants.TimesOfDay.allCases.filter { groupedSubgoals.keys.contains($0)
                }) { timeOfDay in
                    NavigationLink(
                        destination: AnalysisView(
                            timeOfDay: timeOfDay,
                            subgoals: groupedSubgoals[timeOfDay] ?? [])
                    ) {
                        TimeOfDayRowView(timeOfDay)
                    }
                    .font(.custom("Jura", size: 17))
                }
        } header: {
            Text("Время дня")
                .font(Constants.Fonts.juraSubheadline)
        }
    }
    
    func TimeOfDayRowView(_ timeOfDay: Constants.TimesOfDay) -> some View {
        LabeledContent(timeOfDay.rawValue) {
            HStack {
                CheckmarkImageView(for: timeOfDay)
                    .foregroundStyle(.accent)
                Text(String(groupedSubgoals[timeOfDay]?.count ?? 0))
            }
            .fontWeight(.medium)
        }
    }
    
    func CheckmarkImageView(for timeOfDay: Constants.TimesOfDay) -> some View {
        groupedSubgoals.keys.contains(timeOfDay) &&
        reflections.contains(
            where: { $0.timeOfDay ?? "" == timeOfDay.rawValue })
        ? Image(systemName: "checkmark")
        : Image(systemName: "")
    }
    
    func SummarySectionView() -> some View {
        Section {
            if reflections.isEmpty {
                RowLabelView(type: .empty, text: "Пока недостаточно данных")
            } else {
                VStack {
                    ForEach(
                        getGroupedValues(), id: \.0.rawValue
                    ) { lifeArea, text, progress in
                        LabeledContent {
                            ProgressView(value: progress)
                                .frame(width: 150)
                                .tint(lifeArea.color)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(lifeArea.rawValue)
                                    .fontWeight(.medium)
                                Text(text)
                                    .font(.custom("Jura", size: 13))
                            }
                        }
                        .foregroundStyle(lifeArea.color)
                        .font(.custom("Jura", size: 17))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    isModalPresented = true
                }
            }
        } header: {
            Text("Итоги")
                .font(Constants.Fonts.juraSubheadline)
        } footer: {
            if !reflections.isEmpty {
                let ending = reflections.count == 1 ? "анализа" : "анализов"
                Text("Данные на основе \(reflections.count) само\(ending). Нажмите, чтобы узнать подробнее.")
                    .font(Constants.Fonts.juraFootnote)
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
