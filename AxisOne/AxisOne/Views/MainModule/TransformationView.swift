//
//  TransformationView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.08.2025.
//

import SwiftUI

struct TransformationView: View {
    
    // MARK: - Private Properties
    @Environment(\.subgoalService) private var subgoalService
    @Environment(\.goalService) private var goalService
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isCompleted == false"))
    private var goals: FetchedResults<Goal>
    
    @State private var selectedLifeArea: LifeAreas = .health
    @State private var selectedGoal: Goal?
    @State private var isGoalsPresented: Bool = false
    @State private var isAlertPresented: Bool = false
    
    // MARK: - Public Properties
    let subgoal: Subgoal
    @Binding var isModalViewPresented: Bool
    
    // MARK: - Body
    var body: some View {
        List {
            ToGoalSection()
            ToTaskSection()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Преобразовать")
                    .font(Constants.Fonts.juraHeadline)
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
    
    // MARK: - Private Methods
    private func saveAsGoal() {
        do {
            try subgoalService.transformToGoal(
                subgoal,
                lifeArea: selectedLifeArea,
                title: subgoal.title ?? "",
                notes: subgoal.notes ?? ""
            )
        } catch {
            print(error)
        }
    }
    
    private func saveAsTask() {
        do {
            try subgoalService.transformToTask(subgoal, for: selectedGoal)
        } catch {
            print(error)
        }
    }
    
    private func dismiss() {
        DispatchQueue.main.async {
            isModalViewPresented = false
        }
    }
}

// MARK: - Views
private extension TransformationView {
    
    func ToGoalSection() -> some View {
        Section("В цель") {
            ButtonMenuView(
                title: "Сфера жизни",
                items: LifeAreas.allCases,
                selectedItem: $selectedLifeArea,
                itemText: { $0.rawValue },
                itemColor: { $0.color })
            SaveButton {
                do {
                    if try goalService.hasDuplicate(
                        by: subgoal.title ?? ""
                    ) {
                        isAlertPresented = true
                        return
                    }
                } catch {
                    print(error)
                }
                saveAsGoal()
                dismiss()
            }
        }
    }
    
    func SaveButton(action: @escaping () -> Void) -> some View {
        Button("Сохранить") {
            action()
        }
        .font(Constants.Fonts.juraMediumBody)
        .frame(maxWidth: .infinity)
    }
    
    func ToTaskSection() -> some View {
        Section("В задачу") {
            LabeledGoalIndicator()
                .onTapGesture {
                    withAnimation(.snappy) {
                        isGoalsPresented.toggle()
                    }
                }
            if isGoalsPresented {
                UncompletedGoalsView()
            }
            SaveButton {
                saveAsTask()
                dismiss()
            }
            .disabled(selectedGoal == nil)
        }
    }
    
    func LabeledGoalIndicator() -> some View {
        LabeledContent("Родительская цель") {
            Text(selectedGoal == nil ? "Не выбрана" : "Выбрана")
                .fontWeight(.medium)
                .foregroundStyle(selectedGoal != nil ? .accent : .secondary)
        }
        .font(Constants.Fonts.juraBody)
        .contentShape(.rect)
    }
    
    func UncompletedGoalsView() -> some View {
        ForEach(goals) { goal in
            HStack {
                RowTextView(
                    primaryText: goal.title ?? "",
                    secondaryText: goal.notes,
                    isActive: goal.isActive,
                    isCompleted: goal.isCompleted,
                    activeColor: .primary)
                if selectedGoal == goal {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                }
            }
            .onTapGesture {
                selectedGoal = goal
                withAnimation(.snappy) {
                    isGoalsPresented = false
                }
            }
        }
    }
}
