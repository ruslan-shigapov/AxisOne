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
        
    @State private var selectedSubgoalType: SubgoalTypes
    @State private var title: String
    @State private var notes: String
    @State private var isUrgent = false
    @State private var isExactly = false
    @State private var selectedStartDate: Date
    @State private var selectedDeadline: Date
    @State private var selectedTime: Date
    @State private var selectedTimeOfDay: TimesOfDay
    @State private var partCompletion: Double
    @State private var selectedHabitFrequency: Frequencies
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Public Properties
    let lifeArea: LifeAreas?
    let subgoal: Subgoal?
    @Binding var subgoals: [Subgoal]
    @Binding var isModified: Bool
    @Binding var isModalPresentation: Bool
        
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
                MainSection()
                    .disabled(subgoal?.isCompleted ?? false)
                if let subgoal, lifeArea == nil {
                    TransformationLink(for: subgoal)
                }
                if let subgoal {
                    DeleteButton(for: subgoal)
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
                    Text(subgoal?.type ?? "Новая подцель")
                        .font(Constants.Fonts.juraHeadline)
                }
                if isModalPresentation {
                    ToolbarItem {
                        CancelToolbarButton()
                    }
                }
            }
        }
    }
    
    // MARK: - Initialize
    init(
        lifeArea: LifeAreas? = nil,
        subgoal: Subgoal? = nil,
        subgoals: Binding<[Subgoal]>,
        isModified: Binding<Bool>,
        isModalPresentation: Binding<Bool> = .constant(false)
    ) {
        self.lifeArea = lifeArea
        self.subgoal = subgoal
        self._subgoals = subgoals
        self._isModified = isModified
        self._isModalPresentation = isModalPresentation
        let subgoalType = SubgoalTypes(rawValue: subgoal?.type ?? "")
        _selectedSubgoalType = State(initialValue: subgoalType ?? .task)
        if lifeArea == nil, subgoal == nil {
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
        let timeOfDay = TimesOfDay(rawValue: subgoal?.timeOfDay ?? "")
        let currentTimeOfDay = TimesOfDay.getValue(from: .now)
        _selectedTimeOfDay = State(initialValue: timeOfDay ?? currentTimeOfDay)
        if let _ = subgoal?.time {
            isExactly = true
        }
        _selectedTime = State(initialValue: subgoal?.time ?? Date())
        _partCompletion = State(initialValue: subgoal?.completion ?? 25)
        let frequency = Frequencies(rawValue: subgoal?.frequency ?? "")
        _selectedHabitFrequency = State(initialValue: frequency ?? .daily)
    }
}

// MARK: - Views
private extension DetailSubgoalView {
    
    // TODO: сделать потом для каждого типа универсальную секцию и вынести 
    func MainSection() -> some View {
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
            if selectedSubgoalType == .habit, lifeArea != nil {
                DateGroupView(
                    title: "Приступить",
                    selectedDate: $selectedStartDate)
                ButtonMenuView(
                    title: "Повторять",
                    items: Frequencies.allCases,
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
            SaveSubgoalButtonView(
                isModalPresentation: isModalPresentation,
                lifeArea: lifeArea,
                subgoal: subgoal,
                selectedSubgoalType: selectedSubgoalType,
                title: title,
                notes: notes,
                isUrgent: isUrgent,
                selectedDeadline: selectedDeadline,
                isExactly: isExactly,
                selectedTime: selectedTime,
                selectedTimeOfDay: selectedTimeOfDay,
                partCompletion: partCompletion,
                selectedStartDate: selectedStartDate,
                selectedHabitFrequency: selectedHabitFrequency,
                subgoals: $subgoals
            ) {
                isModified.toggle()
                DispatchQueue.main.async {
                    dismiss()
                }
            }
            .disabled(!isFormValid)
        }
    }
    
    func TransformationLink(for subgoal: Subgoal) -> some View {
        NavigationLink(
            destination: TransformationView(
                subgoal: subgoal,
                isModalViewPresented: $isModalPresentation)
        ) {
            RowLabelView(type: .link, text: "Преобразовать")
        }
    }
    
    func DeleteButton(for subgoal: Subgoal) -> some View {
        DeleteButtonView {
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
    
    func CancelToolbarButton() -> some View {
        Button {
            dismiss()
        } label: {
            ToolbarButtonImageView(type: .cancel)
        }
    }
}

#Preview {
    DetailSubgoalView(
        lifeArea: nil,
        subgoals: .constant([]),
        isModified: .constant(false))
}
