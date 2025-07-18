//
//  DetailGoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct DetailGoalView: View {
    
    // MARK: - Private Properties
    @State private var selectedLifeArea: Constants.LifeAreas
    
    @State private var isModified = false
    
    @State private var title: String
    @State private var notes: String
    
    @State private var subgoals: [Subgoal]
        
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isModified
    }
    
    // MARK: - Public Properties
    var goal: Goal?
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                LifeAreaPickerView()
                    .onChange(of: selectedLifeArea) {
                        isModified = true
                    }
                Section {
                    TextFieldView(
                        placeholder: "Сформулируйте цель",
                        text: $title)
                    TextFieldView(
                        placeholder: "Добавьте уточнение",
                        text: $notes)
                } footer: {
                    Text("Необязательно, но полезно, если необходимо держать в фокусе некоторые подробности.")
                }
                Section("Подцели") {
                    NavigationLink(
                        destination: DetailSubgoalView(
                            lifeArea: selectedLifeArea,
                            subgoals: $subgoals,
                            isModified: $isModified)
                    ) {
                        Text("Добавить")
                            .foregroundStyle(.blue)
                    }
                    SubgoalListView()
                }
                if let goal {
                    DeleteButtonView(goal)
                }
            }
            .navigationTitle(goal == nil ? "Новая цель" : "Детали")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CancelButtonView()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    DoneButtonView()
                        .disabled(!isFormValid)
                        .foregroundStyle(isFormValid ? .blue : .secondary)
                }
            }
        }
    }
    
    // MARK: - Initialize
    init(goal: Goal? = nil) {
        self.goal = goal
        _selectedLifeArea = State(
            initialValue: Constants.LifeAreas(
                rawValue: goal?.lifeArea ?? "") ?? .health)
        _title = State(initialValue: goal?.title ?? "")
        _notes = State(initialValue: goal?.notes ?? "")
        _subgoals = State(
            initialValue: (goal?.subgoals as? Set<Subgoal>)?.sorted(
                by: { $0.order < $1.order }) ?? [])
    }
    
    // MARK: - Private Methods
    private func save() {
        let goalToSave = goal ?? Goal(context: context)
        goalToSave.lifeArea = selectedLifeArea.rawValue
        goalToSave.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        goalToSave.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        goalToSave.isActive = goal?.isActive ?? false
        goalToSave.isCompleted = goal?.isCompleted ?? false
        if goal == nil {
            goalToSave.order = getOrder()
        }
        let oldSubgoals = goalToSave.subgoals as? Set<Subgoal> ?? []
        for subgoal in oldSubgoals.subtracting(subgoals) {
            goalToSave.removeFromSubgoals(subgoal)
            context.delete(subgoal)
        }
        goalToSave.subgoals = nil
        for (index, subgoal) in subgoals.enumerated() {
            goalToSave.addToSubgoals(subgoal)
            subgoal.order = Int16(index)
            subgoal.isActive = goalToSave.isActive
        }
        try? context.save()
    }
    
    private func getOrder() -> Int16 {
        let fetchRequest = Goal.fetchRequest()
        fetchRequest.predicate = .init(
            format: "lifeArea == %@",
            argumentArray: [selectedLifeArea.rawValue])
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: true)]
        let lastGoal = try? context.fetch(fetchRequest).last
        return (lastGoal?.order ?? 0) + 1
    }
}

// MARK: - Views
private extension DetailGoalView {
    
    func LifeAreaPickerView() -> some View {
        Picker("Сфера жизни", selection: $selectedLifeArea) {
            ForEach(Constants.LifeAreas.allCases) {
                Text($0.rawValue)
            }
        }
    }
    
    func TextFieldView(
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        TextField(placeholder, text: text)
            .onChange(of: text.wrappedValue) { 
                isModified = true
            }
    }
    
    func SubgoalListView() -> some View {
        List {
            ForEach(subgoals) { subgoal in
                NavigationLink(
                    destination: DetailSubgoalView(
                        lifeArea: selectedLifeArea,
                        subgoal: subgoal,
                        subgoals: $subgoals,
                        isModified: $isModified)
                ) {
                    if subgoal.type == Constants.SubgoalTypes.task.rawValue ||
                       subgoal.type == Constants.SubgoalTypes.part.rawValue,
                       subgoal.isCompleted {
                        SubgoalRowView(subgoal)
                            .foregroundStyle(.secondary)
                    } else {
                        SubgoalRowView(subgoal)
                    }
                }
            }
        }
    }
    
    func SubgoalRowView(_ subgoal: Subgoal) -> some View {
        HStack {
            Image(
                systemName: (
                    Constants.SubgoalTypes(
                        rawValue: subgoal.type ?? "")?.imageName) ?? "")
                .font(.system(size: 22))
                .foregroundStyle(.secondary)
            Text(subgoal.title ?? "")
        }
    }
    
    func DeleteButtonView(_ goal: Goal) -> some View {
        Button("Удалить цель") {
            context.delete(goal)
            try? context.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
        .foregroundStyle(.red)
    }
    
    func CancelButtonView() -> some View {
        Button("Отмена") {
            dismiss()
        }
        .foregroundStyle(.red)
    }
    
    func DoneButtonView() -> some View {
        Button("Готово") {
            save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
    }
}

#Preview {
    DetailGoalView()
}
