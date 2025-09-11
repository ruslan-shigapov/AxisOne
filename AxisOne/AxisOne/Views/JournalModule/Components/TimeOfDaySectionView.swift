//
//  TimeOfDaySectionView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 11.09.2025.
//

import SwiftUI

struct TimeOfDaySectionView: View {
    
    let groupedSubgoals: [TimesOfDay: [Subgoal]]
    let reflections: FetchedResults<Reflection>
    
    var body: some View {
        Section {
            ForEach(
                TimesOfDay.allCases.filter { groupedSubgoals.keys.contains($0) }
            ) {
                TimeOfDayLink($0)
            }
        } header: {
            Text("Время дня")
                .font(Constants.Fonts.juraMediumSubheadline)
        }
    }
    
    func TimeOfDayLink(_ timeOfDay: TimesOfDay) -> some View {
        NavigationLink(
            destination: AnalysisView(
                timeOfDay: timeOfDay,
                subgoals: groupedSubgoals[timeOfDay] ?? [])
        ) {
            TimeOfDayRowView(timeOfDay)
        }
    }
    
    func TimeOfDayRowView(_ timeOfDay: TimesOfDay) -> some View {
        LabeledContent(timeOfDay.rawValue) {
            HStack {
                CheckmarkImage(for: timeOfDay)
                    .foregroundStyle(.accent)
                Text(String(groupedSubgoals[timeOfDay]?.count ?? 0))
            }
        }
        .font(Constants.Fonts.juraBody)
    }
    
    func CheckmarkImage(for timeOfDay: TimesOfDay) -> some View {
        groupedSubgoals.keys.contains(timeOfDay) &&
        reflections.contains(
            where: { $0.timeOfDay ?? "" == timeOfDay.rawValue })
        ? Image(systemName: "checkmark")
        : Image(systemName: "")
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
