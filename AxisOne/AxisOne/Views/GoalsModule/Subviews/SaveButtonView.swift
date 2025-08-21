//
//  SaveButtonView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUI

struct SaveButtonView: View {
    
    @Environment(\.subgoalService) private var subgoalService

    let isModalPresentation: Bool
    let lifeArea: Constants.LifeAreas?
    let subgoal: Subgoal?
    let selectedSubgoalType: Constants.SubgoalTypes
    let title: String
    let notes: String
    let isUrgent: Bool
    let selectedDeadline: Date
    let isExactly: Bool
    let selectedTime: Date
    let selectedTimeOfDay: Constants.TimesOfDay
    let partCompletion: Double
    let selectedStartDate: Date
    let selectedHabitFrequency: Constants.Frequencies
    @Binding var subgoals: [Subgoal]
    let completion: () -> Void
    
    var body: some View {
        Button("Сохранить") {
            do {
                if isModalPresentation {
                    try subgoalService.update(
                        subgoal,
                        type: selectedSubgoalType,
                        title: title,
                        notes: notes,
                        isUrgent: isUrgent,
                        deadline: selectedDeadline,
                        isExactly: isExactly,
                        time: selectedTime,
                        timeOfDay: selectedTimeOfDay,
                        partCompletion: partCompletion,
                        startDate: selectedStartDate,
                        habitFrequency: selectedHabitFrequency
                    )
                } else {
                    try subgoalService.save(
                        subgoal,
                        type: selectedSubgoalType,
                        title: title,
                        notes: notes,
                        isUrgent: isUrgent,
                        deadline: selectedDeadline,
                        isExactly: isExactly,
                        time: selectedTime,
                        timeOfDay: selectedTimeOfDay,
                        partCompletion: partCompletion,
                        startDate: selectedStartDate,
                        habitFrequency: selectedHabitFrequency,
                        lifeArea: lifeArea
                    ) {
                        if let subgoal,
                           let index = subgoals.firstIndex(of: subgoal) {
                            subgoals[index] = $0
                        } else {
                            subgoals.insert($0, at: 0)
                        }
                    }
                }
            } catch {
                print(error)
            }
            completion()
        }
        .font(Constants.Fonts.juraMediumBody)
        .frame(maxWidth: .infinity)
    }
}
