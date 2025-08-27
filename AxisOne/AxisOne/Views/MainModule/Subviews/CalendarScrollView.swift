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
        guard let yesterday = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: today
        ) else {
            return []
        }
        let allDates = subgoals.compactMap {
            return switch $0.type {
            case Constants.SubgoalTypes.task.rawValue: $0.deadline
            case Constants.SubgoalTypes.milestone.rawValue: $0.deadline
            case Constants.SubgoalTypes.habit.rawValue: $0.startDate
            case Constants.SubgoalTypes.inbox.rawValue: $0.deadline
            default: nil
            }
        } + [yesterday, today]
        return Set(allDates.map { Calendar.current.startOfDay(for: $0) })
            .filter { $0 >= yesterday }
            .sorted()
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
                            .fontWeight(.medium)
                        Text(dateFormatter.string(from: date))
                        Text(getDaysFromToday(for: date))
                            .font(Constants.Fonts.juraFootnote)
                    }
                    .font(Constants.Fonts.juraBody)
                    .frame(width: 55, height: 60)
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                Calendar.current.isDate(
                                    date,
                                    inSameDayAs: selectedDate)
                                ? .accent
                                : .clear)
                            .stroke(.primary, lineWidth: 0.3)
                    }
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding()
        }
    }
    
    private func getDaysFromToday(for date: Date) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: today,
            to: calendar.startOfDay(for: date))
            .day
        guard let days else { return "???" }
        return if days == 0 {
            Constants.Texts.today
        } else if days == -1 {
            Constants.Texts.yesterday
        } else if days == 1 {
            Constants.Texts.tomorrow
        } else {
            "+ \(days) дн."
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
