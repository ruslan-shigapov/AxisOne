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
    
    @FetchRequest(
        entity: Goal.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isCompleted == false"))
    private var goals: FetchedResults<Goal>
    
    @State private var selectedLifeArea: Constants.LifeAreas = .health
    @State private var selectedGoal: Goal?
    @State private var isGoalsPresented: Bool = false
    
    // MARK: - Public Properties
    let subgoal: Subgoal
    @Binding var isModalViewPresented: Bool
    
    // MARK: - Body
    var body: some View {
        List {
            Section("Цель") {
                ButtonMenuView(
                    title: "Сфера жизни",
                    items: Constants.LifeAreas.allCases,
                    selectedItem: $selectedLifeArea,
                    itemText: { $0.rawValue },
                    itemColor: { $0.color })
                SaveButton {
                    saveAsGoal()
                    dismiss()
                }
            }
            Section("Задачу") {
                LabeledContent("Родительская цель") {
                    Text(selectedGoal == nil ? "Не выбрана" : "Выбрана")
                        .fontWeight(.medium)
                        .foregroundStyle(
                            selectedGoal != nil ? .accent : .secondary)
                }
                .font(Constants.Fonts.juraBody)
                .contentShape(.rect)
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Преобразовать в")
                    .font(Constants.Fonts.juraHeadline)
            }
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
    
    func SaveButton(action: @escaping () -> Void) -> some View {
        Button("Сохранить") {
            action()
        }
        .font(Constants.Fonts.juraMediumBody)
        .frame(maxWidth: .infinity)
    }
    
    func UncompletedGoalsView() -> some View {
        ForEach(goals) { goal in
            HStack {
                ListRowTextView(
                    primaryText: goal.title,
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
