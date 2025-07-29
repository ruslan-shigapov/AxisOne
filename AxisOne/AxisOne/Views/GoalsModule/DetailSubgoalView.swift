//
//  DetailSubgoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct DetailSubgoalView: View {
    
    // MARK: - Private Properties
    @Environment(\.managedObjectContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
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
    
    @State private var isModalPresentation: Bool
    
    @State private var isAlertPresented = false
    
    private let navigationTitle: String
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Public Properties
    var lifeArea: Constants.LifeAreas?
    var subgoal: Subgoal?
    
    @Binding var subgoals: [Subgoal]
    @Binding var isModified: Bool
        
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                if subgoal == nil, lifeArea != nil {
                    SubgoalTypeSectionView()
                }
                Section {
                    TextFieldWithImageView()
                    TextField(
                        "Можете добавить уточнение",
                        text: $notes,
                        axis: .vertical)
                    .font(.custom("Jura", size: 17))
                    if selectedSubgoalType != .habit,
                       selectedSubgoalType != .focus {
                        DeadlineGroupView()
                        if isUrgent {
                            TimeGroupView()
                        }
                    }
                    if selectedSubgoalType == .milestone {
                        CompletionView()
                    }
                    if selectedSubgoalType == .habit {
                        DatePickerView(
                            title: "Приступить",
                            selection: $selectedStartDate)
                        .font(.custom("Jura", size: 17))
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .background(Color("Background"))
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(navigationTitle)
                        .font(.custom("Jura", size: 20))
                        .fontWeight(.bold)
                }
                if isModalPresentation {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Отмена") {
                            dismiss()
                        }
                        .font(.custom("Jura", size: 17))
                        .fontWeight(.medium)
                        .foregroundStyle(.red)
                    }
                    if let subgoal {
                        ToolbarItem {
                            Button(
                                subgoal.isCompleted 
                                ? "Невыполнено"
                                : "Выполнено"
                            ) {
                                subgoal.isCompleted.toggle()
                                try? context.save()
                                DispatchQueue.main.async {
                                    dismiss()
                                }
                            }
                            .font(.custom("Jura", size: 17))
                            .fontWeight(.medium)
                            .foregroundStyle(.accent)
                        }
                    }
                } else {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Назад")
                                    .font(.custom("Jura", size: 17))
                            }
                            .fontWeight(.medium)
                        }
                    }
                }
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
        navigationTitle = subgoal?.type ?? "Новая подцель"
        _selectedSubgoalType = State(
            initialValue: Constants.SubgoalTypes(
                rawValue: subgoal?.type ?? "") ?? .task)
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
        if selectedSubgoalType != .habit, selectedSubgoalType != .focus {
            subgoalToSave.deadline = isUrgent ? selectedDeadline : nil
        }
        if selectedSubgoalType != .focus {
            subgoalToSave.time = isExact ? selectedTime : nil
            subgoalToSave.timeOfDay = isExact ? nil : selectedTimeOfDay.rawValue
            if !isUrgent, selectedSubgoalType != .habit {
                subgoalToSave.timeOfDay = nil
            }
        }
        if selectedSubgoalType == .milestone {
            subgoalToSave.completion = partCompletion
        }
        if selectedSubgoalType == .habit {
            subgoalToSave.startDate = selectedStartDate
            subgoalToSave.frequency = selectedHabitFrequency.rawValue
        }
        if let subgoal, let index = subgoals.firstIndex(of: subgoal) {
            subgoals[index] = subgoalToSave
        } else if lifeArea == nil {
            try? context.save()
        } else {
            subgoals.insert(subgoalToSave, at: 0)
        }
    }
    
    private func update() {
        guard let subgoal else { return }
        subgoal.title = title
        subgoal.notes = notes
        if selectedSubgoalType != .habit, selectedSubgoalType != .focus {
            subgoal.deadline = isUrgent ? selectedDeadline : nil
        }
        if selectedSubgoalType != .focus {
            subgoal.time = isExact ? selectedTime : nil
            subgoal.timeOfDay = isExact ? nil : selectedTimeOfDay.rawValue
            if !isUrgent, selectedSubgoalType != .habit {
                subgoal.timeOfDay = nil
            }
        }
        if selectedSubgoalType == .milestone {
            subgoal.completion = partCompletion
        }
        if selectedSubgoalType == .habit {
            subgoal.startDate = selectedStartDate
            subgoal.frequency = selectedHabitFrequency.rawValue
        }
        try? context.save()
    }
}

// MARK: - Views
private extension DetailSubgoalView {
    
    func SubgoalTypeSectionView() -> some View {
        Section {
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]) {
                    ForEach(Constants.SubgoalTypes.allCases.dropLast()) {
                        ChooseButtonView(for: $0)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color("Background"))
        } header: {
            Text("Тип")
                .font(.custom("Jura", size: 14))
        } footer: {
            Text(selectedSubgoalType.description)
                .font(.custom("Jura", size: 13))
        }
    }
    
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
            .font(.custom("Jura", size: 17))
            .fontWeight(.medium)
            .frame(maxWidth: .infinity, minHeight: 60)
            .foregroundStyle(colorScheme == .dark ? .white : .black)
            .padding(.horizontal)
        }
        .buttonStyle(BorderlessButtonStyle())
        .background(
            ZStack {
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            (lifeArea?.color ?? .clear).opacity(0.45),
                            lifeArea?.color ?? .clear
                        ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
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
            .font(.custom("Jura", size: 17))
        }
    }
    
    func DeadlineGroupView() -> some View {
        Group {
            Toggle("Срок", isOn: $isUrgent)
                .tint(.accent)
            if isUrgent {
                DatePickerView(title: "Дата", selection: $selectedDeadline)
            }
        }
        .font(.custom("Jura", size: 17))
    }
    
    func TimeGroupView() -> some View {
        Group {
            Toggle("Точное время", isOn: $isExact)
                .tint(.accent)
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
        .font(.custom("Jura", size: 17))
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
        .font(.custom("Jura", size: 17))
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
        .font(.custom("Jura", size: 17))
    }
    
    func SaveButtonView() -> some View {
        Button("Сохранить") {
            isModalPresentation ? update() : save()
            isModified.toggle()
            DispatchQueue.main.async {
                dismiss()
            }
        }
        .font(.custom("Jura", size: 17))
        .fontWeight(.medium)
        .frame(maxWidth: .infinity)
    }
    
    func DeleteButtonView(_ subgoal: Subgoal) -> some View {
        Button("Удалить подцель", role: .destructive) {
            isAlertPresented = true
        }
        .font(.custom("Jura", size: 17))
        .fontWeight(.medium)
        .alert("Вы уверены?", isPresented: $isAlertPresented) {
            Button("Удалить", role: .destructive) {
                if isModalPresentation {
                    context.delete(subgoal)
                    try? context.save()
                } else {
                    subgoals.removeAll { $0 == subgoal }
                    isModified.toggle()
                }
                DispatchQueue.main.async {
                    dismiss()
                }
            }
            Button("Отмена", role: .cancel) {}
        }
    }
}

#Preview {
    DetailSubgoalView(
        lifeArea: .personal,
        subgoals: .constant([]),
        isModified: .constant(false))
}
