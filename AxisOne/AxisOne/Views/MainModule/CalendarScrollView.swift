//
//  CalendarScrollView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 31.07.2025.
//

import SwiftUI

struct CalendarScrollView: View {
    
    @FetchRequest(entity: Subgoal.entity(), sortDescriptors: [])
    private var subgoals: FetchedResults<Subgoal>
    
    private let today = Calendar.current.startOfDay(for: .now)
    
    private var dates: [Date] {
        let allDates = subgoals.compactMap {
            return switch $0.type {
            case Constants.SubgoalTypes.task.rawValue: $0.deadline
            case Constants.SubgoalTypes.milestone.rawValue: $0.deadline
            case Constants.SubgoalTypes.habit.rawValue: $0.startDate
            case Constants.SubgoalTypes.inbox.rawValue: $0.deadline
            default: nil
            }
        } + [today]
        let uniqueDates = Set(
            allDates.map { Calendar.current.startOfDay(for: $0) })
            .filter { $0 >= today }
        return Array(uniqueDates).sorted()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.MM"
        return formatter
    }
    
    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter
    }
    
    @Binding var selectedDate: Date

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem()], spacing: 12) {
                ForEach(dates, id: \.self) { date in
                    VStack(spacing: 4) {
                        Text(weekdayFormatter.string(from: date))
                            .foregroundStyle(.secondary)
                        Text(dateFormatter.string(from: date))
                        Text(getDaysFromToday(for: date))
                            .font(.custom("Jura-Light", size: 13))
                    }
                    .font(.custom("Jura-Medium", size: 17))
                    .frame(width: 55, height: 75)
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                Calendar.current.isDate(
                                    date,
                                    inSameDayAs: selectedDate)
                                ? .accent
                                : Color(.secondarySystemBackground))
                    }
                    .onTapGesture {
                        selectedDate = date
                        
                    }
                }
                .padding(1)
                .padding(.top, 15)
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
    
    private func getDaysFromToday(for date: Date) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: today,
            to: calendar.startOfDay(for: date)).day
        guard let days else { return "???" }
        if days == 0 {
            return "Сегодня"
        } else if days == 1 {
            return "Завтра"
        } else {
            return "+ \(days) дн."
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
