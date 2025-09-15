//
//  HistoryView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct HistoryView: View {

    @Environment(\.managedObjectContext) private var context

    @FetchRequest(entity: Reflection.entity(), sortDescriptors: [])
    private var reflections: FetchedResults<Reflection>
    
    @State private var isModalPresented = false
    
    private var groupedReflections: [Date: [Reflection]] {
        Dictionary(grouping: reflections) {
            Calendar.current.startOfDay(for: $0.date ?? Date())
        }
    }
        
    var body: some View {
        ZStack {
            if reflections.isEmpty {
                EmptyStateView(
                    primaryText: "Здесь будут отображаться все ваши отчеты.")
            } else {
                ReportList()
            }
        }
        .navigationTitle("История")
        .background(Color("Background"))
        .scrollContentBackground(.hidden)
    }
    
    
    private func formatForHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    
    private func formatForRow(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, EEEE"
        return formatter.string(from: date)
    }
}

private extension HistoryView {
    
    func ReportList() -> some View {
        List {
            ForEach(
                groupedReflections.sorted { $0.key > $1.key }, id: \.key
            ) { date, reflections in
                Section(formatForHeader(date)) {
                    Text(formatForRow(date))
                        .font(Constants.Fonts.juraBody)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                        .onTapGesture {
                            isModalPresented = true
                        }
                        .sheet(isPresented: $isModalPresented) {
                            ReportView(date: date)
                        }
                        .swipeActions {
                            SwipeActionButtonView(type: .delete) {
                                reflections.forEach {
                                    context.delete($0)
                                }
                                try? context.save()
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    HistoryView()
        .environment(\.managedObjectContext, context)
}
