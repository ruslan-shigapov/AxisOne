//
//  DetailGoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct DetailGoalView: View {
    
    // MARK: - Private Properties
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("isCompletedSubgoalsHidden")
    private var isCompletedSubgoalsHidden: Bool = false
    
    @State private var selectedLifeArea: Constants.LifeAreas
    
    @State private var title: String
    @State private var notes: String
    
    @State private var subgoals: [Subgoal] = []
    
    @State private var isModified = false
    @State private var isSubgoalsModified = false
    
    @State private var isEditing = false
    @State private var editMode: EditMode = .inactive
    
    @State private var isDeleteAlertPresented = false
    @State private var isErrorAlertPresented = false
    
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
                        .font(.custom("Jura", size: 13))
                }
                Section {
                    NavigationLink(
                        destination: DetailSubgoalView(
                            lifeArea: selectedLifeArea,
                            subgoals: $subgoals,
                            isModified: $isSubgoalsModified)
                    ) {
                        Text("Добавить")
                            .font(.custom("Jura", size: 17))
                            .foregroundStyle(.accent)
                            .fontWeight(.medium)
                    }
                    SubgoalListView()
                } header: {
                    SubgoalSectionHeaderView()
                }
                if let goal {
                    DeleteButtonView(goal)
                }
            }
            .onChange(of: isSubgoalsModified) {
                if $1 { isModified = true }
            }
            .navigationBarTitleDisplayMode(.inline)
            .presentationBackground(Color("Background"))
            .scrollContentBackground(.hidden)
            .listRowBackground(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(goal == nil ? "Новая цель" : "Детали")
                        .font(.custom("Jura", size: 20))
                        .fontWeight(.bold)
                }
                ToolbarItem(placement: .topBarLeading) {
                    CancelButtonView()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    DoneButtonView()
                        .disabled(!isFormValid)
                        .foregroundStyle(isFormValid ? .accent : .secondary)
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
            initialValue: (goal?.subgoals as? Set<Subgoal> ?? []).sorted {
                if $0.isCompleted != $1.isCompleted {
                    return !$0.isCompleted
                } else {
                    return $0.order < $1.order
                }
            })
    }
    
    // MARK: - Private Methods
    private func hasDuplicate() -> Bool {
        guard goal == nil else { return false }
        let fetchRequest = Goal.fetchRequest()
        fetchRequest.predicate = .init(
            format: "title ==[c] %@",
            title.trimmingCharacters(in: .whitespacesAndNewlines))
        let count = try? context.count(for: fetchRequest)
        return count ?? 0 > 0
    }
    
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
            context.delete(subgoal)
        }
        for (index, subgoal) in subgoals.enumerated() {
            subgoal.order = Int16(index)
            subgoal.isActive = goalToSave.isActive
            goalToSave.addToSubgoals(subgoal)
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
    
    private func shouldStrikethrough(_ subgoal: Subgoal) -> Bool {
        let type = Constants.SubgoalTypes(rawValue: subgoal.type ?? "")
        return (type == .task || type == .milestone) && subgoal.isCompleted
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
        .font(.custom("Jura", size: 17))
    }
    
    func TextFieldView(
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        TextField(placeholder, text: text)
            .font(.custom("Jura", size: 17))
            .onChange(of: text.wrappedValue) {
                isModified = true
            }
    }
    
    func SubgoalListView() -> some View {
        List {
            ForEach(subgoals.filter {
                !isCompletedSubgoalsHidden || !$0.isCompleted
            }) { subgoal in
                NavigationLink(
                    destination: DetailSubgoalView(
                        lifeArea: selectedLifeArea,
                        subgoal: subgoal,
                        subgoals: $subgoals,
                        isModified: $isSubgoalsModified)
                ) {
                    SubgoalRowView(subgoal)
                }
                .font(.custom("Jura", size: 17))
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
                .foregroundStyle(subgoal.isCompleted
                                 ? .secondary
                                 : .primary)
                .strikethrough(shouldStrikethrough(subgoal))
        }
    }
    
    func DeleteButtonView(_ goal: Goal) -> some View {
        Button("Удалить цель", role: .destructive) {
            isDeleteAlertPresented = true
        }
        .font(.custom("Jura", size: 17))
        .fontWeight(.medium)
        .alert("Вы уверены?", isPresented: $isDeleteAlertPresented) {
            Button("Удалить", role: .destructive) {
                context.delete(goal)
                try? context.save()
                DispatchQueue.main.async {
                    dismiss()
                }
            }
            Button("Отмена", role: .cancel) {}
        }
    }
    
    func SubgoalSectionHeaderView() -> some View {
        LabeledContent("Подцели") {
            Button {
                withAnimation {
                    isCompletedSubgoalsHidden.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(isCompletedSubgoalsHidden
                         ? "Показать"
                         : "Скрыть")
                    Text("заверш.")
                }
            }
        }
        .font(.custom("Jura", size: 14))
    }
    
    func CancelButtonView() -> some View {
        Button("Отмена") {
            context.rollback()
            DispatchQueue.main.async {
                dismiss()
            }
        }
        .font(.custom("Jura", size: 17))
        .fontWeight(.medium)
        .foregroundStyle(.red)
    }
    
    func DoneButtonView() -> some View {
        Button("Готово") {
            if hasDuplicate() {
                isErrorAlertPresented = true
                return
            }
            save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }
        .font(.custom("Jura", size: 17))
        .fontWeight(.medium)
        .alert(
            "Попробуйте снова",
            isPresented: $isErrorAlertPresented,
            actions: {}
        ) {
            Text("Цель с таким названием уже существует.")
        }
    }
}

#Preview {
    DetailGoalView()
}
