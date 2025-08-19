//
//  DetailGoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct DetailGoalView: View {
    
    // MARK: - Private Properties
    @Environment(\.goalService) private var goalService
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
                        do {
                            try goalService.delete(goal)
                        } catch {
                            print(error)
                        }
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
                        goalService.rollback()
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                }
                ToolbarItem {
                    NavBarTextButtonView(type: .done) {
                        do {
                            if try goalService.hasDuplicate(
                                by: title,
                                excludingGoal: goal
                            ) {
                                isAlertPresented = true
                                return
                            }
                            try goalService.save(
                                goal,
                                lifeArea: selectedLifeArea.rawValue,
                                title: title.trimmingCharacters(
                                    in: .whitespacesAndNewlines),
                                notes: notes.trimmingCharacters(
                                    in: .whitespacesAndNewlines),
                                isActive: isActive,
                                subgoals: subgoals)
                        } catch {
                            print(error)
                        }
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
}

#Preview {
    DetailGoalView()
}
