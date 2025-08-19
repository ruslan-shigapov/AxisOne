//
//  DetailSubgoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct DetailSubgoalView: View {
    
    // MARK: - Private Properties
    @Environment(\.subgoalService) private var subgoalService
    @Environment(\.dismiss) private var dismiss
        
    @State private var selectedSubgoalType: Constants.SubgoalTypes
    @State private var title: String
    @State private var notes: String
    @State private var isUrgent = false
    @State private var isExactly = false
    @State private var selectedStartDate: Date
    @State private var selectedDeadline: Date
    @State private var selectedTime: Date
    @State private var selectedTimeOfDay: Constants.TimesOfDay
    @State private var partCompletion: Double
    @State private var selectedHabitFrequency: Constants.Frequencies
    @State private var isModalPresentation: Bool
    @State private var isConfirmationDialogPresented = false
            
    private let currentTimeOfDay = Constants.TimesOfDay.getTimeOfDay(from: .now)
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Public Properties
    let lifeArea: Constants.LifeAreas?
    let subgoal: Subgoal?
    @Binding var subgoals: [Subgoal]
    @Binding var isModified: Bool
        
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                if subgoal == nil, lifeArea != nil {
                    SubgoalTypeSectionView(
                        selectedSubgoalType: $selectedSubgoalType,
                        lifeArea: lifeArea
                    ) {
                        isUrgent = false
                        isExactly = false
                        selectedStartDate = Date()
                        selectedDeadline = Date()
                    }
                }
                Section {
                    HStack {
                        Image(systemName: selectedSubgoalType.imageName)
                            .imageScale(.large)
                            .foregroundStyle(.secondary)
                        TextFieldView(
                            placeholder: selectedSubgoalType.placeholder,
                            text: $title)
                    }
                    TextFieldView(
                        placeholder: "Можете добавить уточнение",
                        text: $notes)
                    if selectedSubgoalType == .habit {
                        DateGroupView(
                            title: "Приступить",
                            selectedDate: $selectedStartDate)
                        ButtonMenuView(
                            title: "Повторять",
                            items: Constants.Frequencies.allCases,
                            selectedItem: $selectedHabitFrequency,
                            itemText: { $0.rawValue })
                    }
                    if selectedSubgoalType != .habit,
                       selectedSubgoalType != .focus {
                        ToggleView(title: "Срок", isOn: $isUrgent)
                        if isUrgent {
                            DateGroupView(
                                title: "Дата",
                                selectedDate: $selectedDeadline)
                        }
                    }
                    if isUrgent || selectedSubgoalType == .habit {
                        TimeGroupView(
                            isExactly: $isExactly,
                            selectedTime: $selectedTime,
                            selectedTimeOfDay: $selectedTimeOfDay)
                    }
                    if selectedSubgoalType == .milestone {
                        CompletionView(value: $partCompletion)
                    }
                    SaveButtonView {
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
                                       let index = subgoals.firstIndex(
                                        of: subgoal) {
                                        subgoals[index] = $0
                                    } else {
                                        subgoals.insert($0, at: 0)
                                    }
                                }
                            }
                        } catch {
                            print(error)
                        }
                        isModified.toggle()
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                    .disabled(!isFormValid)
                }
                .disabled(subgoal?.isCompleted ?? false)
                if let _ = subgoal, lifeArea == nil {
                    ActionSectionView {
                        isConfirmationDialogPresented = true
                    }
                }
                if let subgoal {
                    DeleteButtonView(title: "Удалить подцель") {
                        if isModalPresentation {
                            do {
                                try subgoalService.delete(subgoal)
                            } catch {
                                print(error)
                            }
                        } else {
                            subgoals.removeAll { $0 == subgoal }
                            isModified.toggle()
                        }
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                }
            }
            .onChange(of: isUrgent) {
                if $1 {
                    isExactly = false
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavBarTitleView(text: subgoal?.type ?? "Новая подцель")
                }
                if isModalPresentation {
                    ToolbarItem {
                        Button {
                            dismiss()
                        } label: {
                            NavBarButtonImageView(type: .cancel)
                        }
                    }
                }
            }
            .confirmationDialog(
                "Выберите сферу жизни",
                isPresented: $isConfirmationDialogPresented,
                titleVisibility: .visible
            ) {
                ForEach(Constants.LifeAreas.allCases) { lifeArea in
                    Button(lifeArea.rawValue) {
                        do {
                            try subgoalService.transformToGoal(
                                subgoal,
                                lifeArea: lifeArea,
                                title: title,
                                notes: notes
                            )
                        } catch {
                            print(error)
                        }
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                    .foregroundStyle(.white)
                }
                Button("Отмена", role: .cancel) {}
            }
        }
    }
    
    // MARK: - Initialize
    init(
        lifeArea: Constants.LifeAreas? = nil,
        subgoal: Subgoal? = nil,
        subgoals: Binding<[Subgoal]>,
        isModified: Binding<Bool>,
        isModalPresentation: Bool = false
    ) {
        self.lifeArea = lifeArea
        self.subgoal = subgoal
        self._subgoals = subgoals
        self._isModified = isModified
        self.isModalPresentation = isModalPresentation
        let subgoalType = Constants.SubgoalTypes(rawValue: subgoal?.type ?? "")
        _selectedSubgoalType = State(initialValue: subgoalType ?? .task)
        if lifeArea == nil {
            _selectedSubgoalType = State(initialValue: .inbox)
        }
        _title = State(initialValue: subgoal?.title ?? "")
        _notes = State(initialValue: subgoal?.notes ?? "")
        _selectedStartDate = State(initialValue: subgoal?.startDate ?? Date())
        if let deadline = subgoal?.deadline {
            isUrgent = true
            _selectedDeadline = State(initialValue: deadline)
        } else {
            _selectedDeadline = State(initialValue: Date())
        }
        let timeOfDay = Constants.TimesOfDay(rawValue: subgoal?.timeOfDay ?? "")
        _selectedTimeOfDay = State(initialValue: timeOfDay ?? currentTimeOfDay)
        if let _ = subgoal?.time {
            isExactly = true
        }
        _selectedTime = State(initialValue: subgoal?.time ?? Date())
        _partCompletion = State(initialValue: subgoal?.completion ?? 25)
        let frequency = Constants.Frequencies(
            rawValue: subgoal?.frequency ?? "")
        _selectedHabitFrequency = State(initialValue: frequency ?? .daily)
    }
}

#Preview {
    DetailSubgoalView(
        lifeArea: nil,
        subgoals: .constant([]),
        isModified: .constant(false))
}
