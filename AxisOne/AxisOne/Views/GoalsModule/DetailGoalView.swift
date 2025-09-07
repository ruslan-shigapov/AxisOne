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
    
    @AppStorage("isCompletedHidden")
    private var isCompletedHidden = false
    
    @State private var selectedLifeArea: LifeAreas
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
                    items: LifeAreas.allCases,
                    selectedItem: $selectedLifeArea,
                    itemText: { $0.rawValue },
                    itemColor: { $0.color })
                .onChange(of: selectedLifeArea) {
                    isModified = true
                }
                TextFieldSection()
                ToggleView(title: "Приоритет", isOn: $isActive)
                    .onChange(of: isActive) {
                        isModified = true
                    }
                SubgoalSectionView(
                    selectedLifeArea: selectedLifeArea,
                    subgoals: $subgoals,
                    isModified: $isSubgoalsModified,
                    isCompletedHidden: $isCompletedHidden)
                if let goal {
                    DeleteButton(for: goal)
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
                    Text(goal == nil ? "Новая цель" : "Детали")
                        .font(Constants.Fonts.juraHeadline)
                }
                ToolbarItem(placement: .topBarLeading) {
                    CancelToolbarButton()
                }
                ToolbarItem {
                    DoneToolbarButton()
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
        let lifeArea = LifeAreas(rawValue: goal?.lifeArea ?? "")
        _selectedLifeArea = State(initialValue: lifeArea ?? .health)
        _isActive = State(initialValue: goal?.isActive ?? false)
        _title = State(initialValue: goal?.title ?? "")
        _notes = State(initialValue: goal?.notes ?? "")
        let subgoals = goal?.subgoals as? Set<Subgoal> ?? []
        _subgoals = State(
            initialValue: subgoals.sorted {
                if $0.isCompleted != $1.isCompleted {
                    !$0.isCompleted
                } else {
                    $0.order < $1.order
                }
            })
    }
}

// MARK: - Views
private extension DetailGoalView {
    
    func TextFieldSection() -> some View {
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
    }
    
    func DeleteButton(for goal: Goal) -> some View {
        DeleteButtonView(title: "Удалить цель") {
            do {
                try goalService.delete(goal)
            } catch {
                print(error)
            }
            DispatchQueue.main.async {
                dismiss()
            }
        }
    }
    
    func CancelToolbarButton() -> some View {
        ToolbarTextButtonView(type: .cancel) {
            goalService.rollback()
            DispatchQueue.main.async {
                dismiss()
            }
        }
    }
    
    func DoneToolbarButton() -> some View {
        ToolbarTextButtonView(type: .done) {
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
    }
}

#Preview {
    DetailGoalView()
}
