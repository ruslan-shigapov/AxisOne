//
//  TimeGroupView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUI

struct TimeGroupView: View {
    
    @State private var isPickerPresented: Bool = false
    
    @Binding var isExactly: Bool
    @Binding var selectedTime: Date
    @Binding var selectedTimeOfDay: Constants.TimesOfDay
    
    var body: some View {
        ToggleView(title: "Точное время", isOn: $isExactly)
        if isExactly {
            LabeledDateView(title: "Напомнить",  value: format(selectedTime))
                .onTapGesture {
                    withAnimation {
                        isPickerPresented.toggle()
                    }
                }
            if isPickerPresented {
                DatePicker(
                    "",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
            }
        } else {
            ButtonMenuView(
                title: "Время дня",
                items: Constants.TimesOfDay.allCases.dropLast(),
                selectedItem: $selectedTimeOfDay,
                itemText: { $0.rawValue })
        }
    }
    
    private func format(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
}
