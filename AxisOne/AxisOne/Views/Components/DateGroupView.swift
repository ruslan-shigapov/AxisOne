//
//  DateGroupView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUI

struct DateGroupView: View {
    
    @State private var isPickerPresented: Bool = false
    
    let title: String
    @Binding var selectedDate: Date

    var body: some View {
        LabeledDateView(title: title, value: format(selectedDate))
            .onTapGesture {
                withAnimation(.snappy) {
                    isPickerPresented.toggle()
                }
            }
        if isPickerPresented {
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
        }
    }
    
    private func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return if Calendar.current.isDateInToday(date) {
            Constants.Texts.today
        } else if Calendar.current.isDateInYesterday(date) {
            Constants.Texts.yesterday
        } else if Calendar.current.isDateInTomorrow(date) {
            Constants.Texts.tomorrow
        } else {
            formatter.string(from: date)
        }
    }
}
