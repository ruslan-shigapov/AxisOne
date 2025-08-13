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
    
    @State private var isDatePickerPresented: Bool = false
    @State private var isTimePickerPresented: Bool = false
    
    @State private var isUrgent = false
    @State private var isExact = false
    
    @State private var selectedStartDate: Date
    @State private var selectedDeadline: Date
    @State private var selectedTime: Date
    
    @State private var selectedTimeOfDay: Constants.TimesOfDay
    
    @State private var partCompletion: Double
    
    @State private var selectedHabitFrequency: Constants.Frequencies
    
    @State private var isModalPresentation: Bool
            
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
                    SubgoalTypeSectionView()
                }
                Section {
                    TextFieldWithImageView()
                    TextFieldView(
                        placeholder: "Можете добавить уточнение",
                        text: $notes)
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
                        DatePickerGroupView(
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
                .disabled(subgoal?.isCompleted ?? false)
                if let subgoal {
                    DeleteButtonView(title: "Удалить подцель") {
                        delete(subgoal)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: isUrgent) { _, newValue in
                if !newValue {
                    isExact = false
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavigationBarTitleView(
                        text: subgoal?.type ?? "Новая подцель")
                }
                if isModalPresentation {
                    ToolbarItem {
                        NavBarImageButtonView(type: .cancel) {
                            dismiss()
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
                rawValue: subgoal?.timeOfDay ?? "") ?? currentTimeOfDay)
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
            subgoalToSave.timeOfDay = isExact
            ? Constants.TimesOfDay.getTimeOfDay(
                from: subgoalToSave.time).rawValue
            : selectedTimeOfDay.rawValue
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
            if !Calendar.current.isDateInToday(selectedDeadline) {
                subgoal.isCompleted = false
            }
            subgoal.deadline = isUrgent ? selectedDeadline : nil
        }
        if selectedSubgoalType != .focus {
            subgoal.time = isExact ? selectedTime : nil
            subgoal.timeOfDay = isExact
            ? Constants.TimesOfDay.getTimeOfDay(
                from: subgoal.time).rawValue
            : selectedTimeOfDay.rawValue
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
    
    private func delete(_ subgoal: Subgoal) {
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        if Calendar.current.isDateInToday(date) {
            return "Сегодня"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Завтра"
        } else {
            return formatter.string(from: date)
        }
    }
    
    private func formatTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
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
                .listRowBackground(Color(.systemBackground))
        } header: {
            HeaderView(text: "Тип")
        } footer: {
            FooterView(text: selectedSubgoalType.description)
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
            .font(.custom("Jura-Medium", size: 17))
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
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.primary, lineWidth: 3)
                }
            })
        .cornerRadius(10)
    }
    
    func TextFieldWithImageView() -> some View {
        HStack {
            Image(systemName: selectedSubgoalType.imageName)
                .imageScale(.large)
                .foregroundStyle(.secondary)
            TextFieldView(
                placeholder: selectedSubgoalType.placeholder,
                text: $title)
        }
    }
    
    func DateRowLabel(title: String, value: String) -> some View {
        LabeledContent(title) {
            Text(value)
                .foregroundStyle(title != "Приступить" ? .accent : .secondary)
        }
        .font(.custom("Jura-Medium", size: 17))
        .background(Rectangle().fill(Color(.secondarySystemBackground)))
    }
    
    func DatePickerGroupView(
        title: String,
        selection: Binding<Date>
    ) -> some View {
        Group {
            DateRowLabel(
                title: title,
                value: formatDate(selection.wrappedValue))
            .onTapGesture {
                withAnimation {
                    isDatePickerPresented.toggle()
                }
            }
            if isDatePickerPresented {
                DatePicker("", selection: selection, displayedComponents: .date)
                    .datePickerStyle(.wheel)
            }
        }
    }
    
    func TimePickerGroupView(
        title: String,
        selection: Binding<Date>
    ) -> some View {
        Group {
            DateRowLabel(
                title: title,
                value: formatTime(selection.wrappedValue))
            .onTapGesture {
                withAnimation {
                    isTimePickerPresented.toggle()
                }
            }
            if isTimePickerPresented {
                DatePicker(
                    "",
                    selection: selection,
                    displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
            }
        }
    }
    
    func DeadlineGroupView() -> some View {
        Group {
            ToggleView(title: "Срок", isOn: $isUrgent)
            if isUrgent {
                DatePickerGroupView(title: "Дата", selection: $selectedDeadline)
            }
        }
    }
    
    func TimeGroupView() -> some View {
        Group {
            ToggleView(title: "Точное время", isOn: $isExact)
            if isExact {
                TimePickerGroupView(
                    title: "Напомнить",
                    selection: $selectedTime)
            } else {
                ButtonMenuView(
                    title: "Время дня",
                    items: Constants.TimesOfDay.allCases.dropLast(),
                    selectedItem: $selectedTimeOfDay,
                    onSelect: { selectedTimeOfDay = $0 },
                    itemText: { $0.rawValue })
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
        .font(.custom("Jura", size: 17))
    }
    
    func RepetitionView() -> some View {
        ButtonMenuView(
            title: "Повторять",
            items: Constants.Frequencies.allCases,
            selectedItem: $selectedHabitFrequency,
            onSelect: { selectedHabitFrequency = $0 },
            itemText: { $0.rawValue })
    }
    
    func SaveButtonView() -> some View {
        Button("Сохранить") {
            isModalPresentation ? update() : save()
            isModified.toggle()
            DispatchQueue.main.async {
                dismiss()
            }
        }
        .font(.custom("Jura-Medium", size: 17))
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DetailSubgoalView(
        lifeArea: .personal,
        subgoals: .constant([]),
        isModified: .constant(false))
}
