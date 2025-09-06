//
//  SettingsView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.subgoalService) private var subgoalService
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var inboxTriage: Subgoal?
    @State private var isInboxTriageEnabled = false
    @State private var selectedTimeOfDay = TimesOfDay.getValue(from: .now)
    @State private var isExactly = false
    @State private var selectedTime = Date()
    @State private var isPickerPresented = false
    
    var body: some View {
        List {
            Section("") {
                ToggleView(
                    title: "Сортировка Входящих",
                    isOn: $isInboxTriageEnabled)
                if isInboxTriageEnabled {
                    TimeGroupView(
                        isExactly: $isExactly,
                        selectedTime: $selectedTime,
                        selectedTimeOfDay: $selectedTimeOfDay)
                }
            }
        }
        .onAppear {
            loadInboxTriage()
        }
        .onDisappear {
            updateInboxTriage()
        }
        .navigationTitle("Настройки")
        .background(
            colorScheme == .dark
            ? Constants.Colors.darkBackground
            : Constants.Colors.lightBackground)
        .scrollContentBackground(.hidden)
    }
    
    private func loadInboxTriage() {
        do {
            inboxTriage = try subgoalService.getInboxTriage()
            isInboxTriageEnabled = inboxTriage != nil
            selectedTimeOfDay = TimesOfDay(
                rawValue: inboxTriage?.timeOfDay ?? "")
            ?? .getValue(from: .now)
            isExactly = inboxTriage?.time != nil
            selectedTime = inboxTriage?.time ?? Date()
        } catch {
            print(error)
        }
    }
    
    private func updateInboxTriage() {
        do {
            if isInboxTriageEnabled {
                try subgoalService.saveInboxTriage(
                    inboxTriage,
                    timeOfDay: selectedTimeOfDay,
                    time: isExactly ? selectedTime : nil)
            } else {
                guard let inboxTriage else { return }
                try subgoalService.delete(inboxTriage)
            }
        } catch {
            print(error)
        }
    }
}

#Preview {
    SettingsView()
}
