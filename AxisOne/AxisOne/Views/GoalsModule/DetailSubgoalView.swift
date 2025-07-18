//
//  DetailSubgoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct DetailSubgoalView: View {
    
    // MARK: - Private Properties
    @State private var selectedSubgoalType: Constants.SubgoalTypes
    
    @State private var title: String
    @State private var notes: String
    
    @State private var isUrgent = false
    @State private var isExact = false
    
    @State private var selectedStartDate: Date
    @State private var selectedDeadline: Date
    @State private var selectedTime: Date
    
    @State private var selectedTimeOfDay: Constants.TimesOfDay
    
    @State private var partCompletion: Double
    
    @State private var selectedHabitFrequency: Constants.Frequencies
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private let navigationTitle: String
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Public Properties
    var lifeArea: Constants.LifeAreas
    var subgoal: Subgoal?
    
    @Binding var subgoals: [Subgoal]
    @Binding var isModified: Bool
        
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                if subgoal == nil {
                    Section {
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ]) {
                                ForEach(Constants.SubgoalTypes.allCases) {
                                    ChooseButtonView(for: $0)
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(
                                Color(.secondarySystemBackground))
                    } header: {
                            Text("Тип")
                    } footer: {
                        Text(selectedSubgoalType.description)
                    }
                }
                Section {
                    TextFieldWithImageView()
                    TextField("Можете добавить уточнение", text: $notes)
                    if selectedSubgoalType == .task ||
                        selectedSubgoalType == .part {
                        DeadlineGroupView()
                        if isUrgent {
                            TimeGroupView()
                        }
                    }
                    if selectedSubgoalType == .part {
                        CompletionView()
                    }
                    if selectedSubgoalType == .habit {
                        DatePickerView(
                            title: "Приступить",
                            selection: $selectedStartDate)
                        RepetitionView()
                    }
                    if selectedSubgoalType == .habit {
                        TimeGroupView()
                    }
                    SaveButtonView()
                        .disabled(!isFormValid)
                }
                if let subgoal {
                    DeleteButtonView(subgoal)
                }
            }
            .onChange(of: isUrgent) { _, newValue in
                if !newValue {
                    isExact = false
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Initialize
    init(
        lifeArea: Constants.LifeAreas,
        subgoal: Subgoal? = nil,
        subgoals: Binding<[Subgoal]>,
        isModified: Binding<Bool>
    ) {
        self.lifeArea = lifeArea
        self.subgoal = subgoal
        self._subgoals = subgoals
        self._isModified = isModified
        navigationTitle = subgoal?.type ?? "Новая подцель"
        _selectedSubgoalType = State(
            initialValue: Constants.SubgoalTypes(
                rawValue: subgoal?.type ?? "") ?? .task)
        _title = State(initialValue: subgoal?.title ?? "")
        _notes = State(initialValue: subgoal?.notes ?? "")
        _selectedStartDate = State(initialValue: subgoal?.startDate ?? Date())
        if let deadline = subgoal?.deadline {
            isUrgent = true
            _selectedDeadline = State(initialValue: deadline)
        } else {
            _selectedDeadline = State(initialValue: Date())
        }
        _selectedTimeOfDay = State(
            initialValue: Constants.TimesOfDay(
                rawValue: subgoal?.timeOfDay ?? "") ?? .morning)
        if let _ = subgoal?.time {
            isExact = true
        }
        _selectedTime = State(initialValue: subgoal?.time ?? Date())
        _partCompletion = State(initialValue: subgoal?.completion ?? 25)
        _selectedHabitFrequency = State(
            initialValue: Constants.Frequencies(
                rawValue: subgoal?.frequency ?? "") ?? .daily)
    }
    
    // MARK: - Private Methods
    private func save() {
        let subgoalToSave = subgoal ?? Subgoal(context: context)
        subgoalToSave.type = selectedSubgoalType.rawValue
        subgoalToSave.title = title
        subgoalToSave.notes = notes
        subgoalToSave.isCompleted = subgoal?.isCompleted ?? false
        if selectedSubgoalType == .task || selectedSubgoalType == .part {
            subgoalToSave.deadline = isUrgent ? selectedDeadline : nil
        }
        if selectedSubgoalType != .rule {
            subgoalToSave.time = isExact ? selectedTime : nil
            subgoalToSave.timeOfDay = isExact ? nil : selectedTimeOfDay.rawValue
        }
        if selectedSubgoalType == .part {
            subgoalToSave.completion = partCompletion
        }
        if selectedSubgoalType == .habit {
            subgoalToSave.startDate = selectedStartDate
            subgoalToSave.frequency = selectedHabitFrequency.rawValue
        }
        if let subgoal {
            subgoals.removeAll { $0 == subgoal }
        }
        subgoals.append(subgoalToSave)
    }
}

// MARK: - Views
private extension DetailSubgoalView {
    
    func ChooseButtonView(for type: Constants.SubgoalTypes) -> some View {
        Button {
            selectedSubgoalType = type
            isUrgent = false
            isExact = false
            selectedStartDate = Date()
            selectedDeadline = Date()
        } label: {
            LabeledContent(type.rawValue) {
                Image(systemName: type.imageName)
                    .imageScale(.large)
            }
            .frame(maxWidth: .infinity, minHeight: 60)
            .foregroundStyle(.black)
            .padding(.horizontal)
        }
        .buttonStyle(BorderlessButtonStyle())
        .background(
            ZStack {
                lifeArea.color
                if selectedSubgoalType == type {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.primary, lineWidth: 3)
                }
            })
        .cornerRadius(16)
    }
    
    func TextFieldWithImageView() -> some View {
        HStack {
            Image(systemName: selectedSubgoalType.imageName)
                .imageScale(.large)
                .foregroundStyle(.secondary)
            TextField(
                selectedSubgoalType.placeholder,
                text: $title,
                axis: .vertical)
        }
    }
    
    func DeadlineGroupView() -> some View {
        Group {
            Toggle("Срок", isOn: $isUrgent)
                .tint(.blue)
            if isUrgent {
                DatePickerView(title: "Дата", selection: $selectedDeadline)
            }
        }
    }
    
    func CompletionView() -> some View {
        VStack {
            LabeledContent("Составляет от цели") {
                Text("\(Int(partCompletion)) %")
            }
            Slider(
                value: $partCompletion,
                in: 0...100,
                step: 25)
            .onChange(of: partCompletion) { _, value in
                if value == 0 {
                    partCompletion = 25
                }
            }
        }
    }
    
    func RepetitionView() -> some View {
        VStack {
            LabeledContent(
                "Повторять"
            ) {
                Picker(
                    "",
                    selection: $selectedHabitFrequency
                ) {
                    ForEach(Constants.Frequencies.allCases) {
                        Text($0.rawValue)
                    }
                }
            }
        }
    }
    
    func DatePickerView(
        title: String,
        selection: Binding<Date>
    ) -> some View {
        DatePicker(
            title,
            selection: selection,
            displayedComponents: .date)
        .environment(
            \.locale,
             Locale(identifier: "ru_RU"))
    }
    
    func TimeGroupView() -> some View {
        Group {
            Toggle("Точное время", isOn: $isExact)
                .tint(.blue)
            if isExact {
                DatePicker(
                    "Напомнить",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute)
            } else {
                Picker("Время дня", selection: $selectedTimeOfDay) {
                    ForEach(Constants.TimesOfDay.allCases.dropLast()) {
                        Text($0.rawValue)
                    }
                }
            }
        }
    }
    
    func SaveButtonView() -> some View {
        Button("Сохранить") {
            save()
            DispatchQueue.main.async {
                isModified = true
                dismiss()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    func DeleteButtonView(_ subgoal: Subgoal) -> some View {
        Button("Удалить подцель") {
            subgoals.removeAll { $0 == subgoal }
            DispatchQueue.main.async {
                isModified = true
                dismiss()
            }
        }
        .foregroundStyle(.red)
    }
}

#Preview {
    DetailSubgoalView(
        lifeArea: .health,
        subgoals: .constant([]),
        isModified: .constant(false))
}
