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
    private var isCompletedSubgoalsHidden = false
    
    @State private var selectedLifeArea: Constants.LifeAreas
    @State private var title: String
    @State private var notes: String
    @State private var isActive: Bool
    @State private var subgoals: [Subgoal] = []
    @State private var isModified = false
    @State private var isSubgoalsModified = false
    @State private var isAlertPresented = false
    
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
                ButtonMenuView(
                    title: "Сфера жизни",
                    items: Constants.LifeAreas.allCases,
                    selectedItem: $selectedLifeArea,
                    itemText: { $0.rawValue },
                    itemColor: { $0.color })
                .onChange(of: selectedLifeArea) {
                    isModified = true
                }
                Section {
                    TextFieldView(
                        placeholder: "Сформулируйте цель",
                        text: $title)
                    .onChange(of: title) {
                        isModified = true
                    }
                    TextFieldView(
                        placeholder: "Можете добавить уточнение",
                        text: $notes)
                    .onChange(of: notes) {
                        isModified = true
                    }
                }
                ToggleView(title: "Приоритет", isOn: $isActive)
                    .onChange(of: isActive) {
                        isModified = true
                    }
                SubgoalSectionView(
                    selectedLifeArea: selectedLifeArea,
                    subgoals: $subgoals,
                    isModified: $isSubgoalsModified,
                    isCompletedHidden: $isCompletedSubgoalsHidden)
                if let goal {
                    DeleteButtonView(title: "Удалить цель") {
                        delete(goal)
                    }
                }
            }
            .onChange(of: isSubgoalsModified) {
                if $1 {
                    isModified = true
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    NavBarTitleView(text: goal == nil ? "Новая цель" : "Детали")
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavBarTextButtonView(type: .cancel) {
                        context.rollback()
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                }
                ToolbarItem {
                    NavBarTextButtonView(type: .done) {
                        if hasDuplicate() {
                            isAlertPresented = true
                            return
                        }
                        save()
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert(
                "Попробуйте снова",
                isPresented: $isAlertPresented,
                actions: {}
            ) {
                Text("Цель с таким названием уже существует.")
            }
        }
    }
    
    // MARK: - Initialize
    init(goal: Goal? = nil) {
        self.goal = goal
        let lifeArea = Constants.LifeAreas(rawValue: goal?.lifeArea ?? "")
        _selectedLifeArea = State(initialValue: lifeArea ?? .health)
        _isActive = State(initialValue: goal?.isActive ?? false)
        _title = State(initialValue: goal?.title ?? "")
        _notes = State(initialValue: goal?.notes ?? "")
        let subgoals = goal?.subgoals as? Set<Subgoal> ?? []
        _subgoals = State(initialValue: subgoals.sorted {
            if $0.isCompleted != $1.isCompleted {
                !$0.isCompleted
            } else {
                $0.order < $1.order
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
        goalToSave.isActive = isActive
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
            subgoal.isActive = isActive
            goalToSave.addToSubgoals(subgoal)
        }
        do {
            try context.save()
        } catch {
            print("Error goal saving: \(error)")
        }
    }
    
    private func getOrder() -> Int16 {
        let fetchRequest = Goal.fetchRequest()
        fetchRequest.predicate = .init(
            format: "lifeArea == %@",
            selectedLifeArea.rawValue)
        fetchRequest.sortDescriptors = [.init(key: "order", ascending: false)]
        fetchRequest.fetchLimit = 1
        do {
            let lastGoal = try context.fetch(fetchRequest).first
            return (lastGoal?.order ?? 0) + 1
        } catch {
            print("Error goal order getting to save: \(error)")
            return 0
        }
    }
    
    private func delete(_ goal: Goal) {
        context.delete(goal)
        do {
            try context.save()
        } catch {
            print("Error goal deleting by button: \(error)")
        }
        DispatchQueue.main.async {
            dismiss()
        }
    }
}

#Preview {
    DetailGoalView()
}
