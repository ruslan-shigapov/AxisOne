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
    
    @State private var title: String
    @State private var notes: String
    
    @State private var isModified = false
    
    @State private var subgoals: [Subgoal]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    
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
                Picker("Сфера жизни", selection: $selectedLifeArea) {
                    ForEach(Constants.LifeAreas.allCases) {
                        Text($0.rawValue)
                    }
                }
                .onChange(of: selectedLifeArea) { _ in 
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
                        destination: DetailSubgoalView()
                    ) {
                        Text("Добавить")
                            .foregroundStyle(.blue)
                    }
                    if !subgoals.isEmpty {
                        SubgoalListView()
                    }
                }
                if let goal {
                    Button("Удалить цель") {
                        context.delete(goal)
                        try? context.save()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle(goal == nil ? "Новая цель" : "Детали")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        save()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    }
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
            goalToSave.createdAt = Date()
        }
        try? context.save()
    }
}

// MARK: - Views
private extension DetailGoalView {
    
    func TextFieldView(
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        TextField(placeholder, text: text, axis: .horizontal)
            .onChange(of: text.wrappedValue) { _ in
                isModified = true
            }
        // TODO: SETUP
    }
    
    func SubgoalListView() -> some View {
        List {
            ForEach(subgoals) { subgoal in
                NavigationLink(
                    destination: DetailSubgoalView(subgoal: subgoal)
                ) {
                    Text(subgoal.title ?? "")
                    // TODO: SETUP
                }
            }
        }
    }
}

#Preview {
    DetailGoalView()
}
