//
//  SummarySectionView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 11.09.2025.
//

import SwiftUI

struct SummarySectionView: View {
        
    // MARK: - Private Properties
    @State private var isModalViewPresented = false
    
    // MARK: - Public Properties
    let groupedSubgoals: [TimesOfDay: [Subgoal]]
    let reflections: FetchedResults<Reflection>
    let subgoals: FetchedResults<Subgoal>
       
    // MARK: - Body
    var body: some View {
        Section {
            if reflections.isEmpty {
                RowLabelView(type: .empty, text: "Пока недостаточно данных")
            } else {
                SummaryView()
                    .onTapGesture {
                        isModalViewPresented = true
                    }
            }
        } header: {
            Text("Итоги")
                .font(Constants.Fonts.juraMediumSubheadline)
        } footer: {
            if !reflections.isEmpty {
                FooterView()
            }
        }
        .sheet(isPresented: $isModalViewPresented) {
            ReportView(date: .now)
        }
    }
    
    // MARK: - Private Methods
    private func getGroupedValues() -> [(LifeAreas, String, Double)] {
        let reflectedSubgoals = reflections
            .compactMap { $0.reactions as? Set<Reaction> }
            .flatMap { $0 }
            .compactMap { $0.subgoal }
        return LifeAreas.allCases.map { lifeArea in
            let matching = reflectedSubgoals.filter {
                let subgoalLifeArea = LifeAreas(
                    rawValue: $0.goal?.lifeArea ?? "")
                return subgoalLifeArea == lifeArea
            }
            let allSubgoals = subgoals.filter {
                $0.goal?.lifeArea ?? "" == lifeArea.rawValue
            }
                .count
            let completedSubgoals = matching.filter(\.isCompleted).count
            let progress = allSubgoals > 0
            ? Double(completedSubgoals) / Double(allSubgoals)
            : 0
            return (lifeArea, "\(completedSubgoals)/\(allSubgoals)", progress)
        }
    }
}

// MARK: - Views
private extension SummarySectionView {
    
    func SummaryView() -> some View {
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
                            .font(Constants.Fonts.juraFootnote)
                    }
                }
                .foregroundStyle(lifeArea.color)
                .font(Constants.Fonts.juraBody)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
    
    @ViewBuilder
    func FooterView() -> some View {
        let ending = reflections.count == 1 ? "анализа" : "анализов"
        Text("""
        Данные на основе \(reflections.count) само\(ending). \
        Нажмите, чтобы узнать подробнее.
        """)
        .font(Constants.Fonts.juraFootnote)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
