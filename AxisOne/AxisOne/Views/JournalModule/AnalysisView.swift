//
//  AnalysisView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct AnalysisView: View {
    
    // MARK: - Private Properties
    @State private var mainThough = ""
    
//    @State private var selectedFeeling: Constants.Feelings = .joy
//    @State private var selectedEmotions: [String]
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
//    private var isFormValid: Bool {
//        !mainThough.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
//        selectedEmotions.count > 4
//    }
    
    // MARK: - Public Properties
    var goal: Goal
    
    // MARK: - Body
    var body: some View {
        Form {
//            Section(subgoal.type ?? "") {
//                Text(subgoal.title ?? "")
//                    .fontWeight(.medium)
//            }
            Section("Размышления") {
                MainTextEditorView()
            }
            Section {
//                FeelingPickerView()
//                EmotionsView()
            } header: {
                HStack {
                    Text("Эмоции")
                    Spacer()
//                    Text(String(selectedEmotions.count))
//                        .fontWeight(.semibold)
                }
            } footer: {
                Text("Выберите хотя бы 5 эмоций для исчерпывающего анализа в будущем. Но и не переусердствуйте.")
            }
        }
        .navigationTitle("Самоанализ")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Готово") {
                    save()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
//                .disabled(!isFormValid)
//                .foregroundStyle(isFormValid ? .blue : .secondary)
            }
        }
    }
    
    // MARK: - Initialize
    init(goal: Goal) {
        self.goal = goal
//        _mainThough = State(initialValue: subgoal.reflection?.mainThough ?? "")
//        _selectedEmotions = State(
//            initialValue: subgoal.reflection?.emotions?.components(
//                separatedBy: " ") ?? [])
    }
    
    // MARK: - Private Methods
    private func save() {
        let reflection = Reflection(context: context)
        reflection.date = Date()
        reflection.mainThough = mainThough
//        reflection.emotions = selectedEmotions.joined(separator: " ")
//        subgoal.reflection = reflection
        try? context.save()
    }
}

// MARK: - Views
private extension AnalysisView {
    
    func MainTextEditorView() -> some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $mainThough)
                .frame(height: 150)
            if mainThough.isEmpty {
                Text("Начните вводить...")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
        }
        // TODO: поменять на обычное текстовое поле?
    }
    
//    func FeelingPickerView() -> some View {
//        Picker("", selection: $selectedFeeling) {
//            ForEach(Constants.Feelings.allCases) {
//                Text($0.rawValue)
//            }
//        }
//        .pickerStyle(.segmented)
//        .padding(.vertical, 4)
//    }
//    
//    func EmotionsView() -> some View {
//        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 4)]) {
//            ForEach(selectedFeeling.emotions, id: \.self) { emotion in
//                EmotionView(emotion, isSelected: selectedEmotions.contains(emotion))
//                    .onTapGesture {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            if selectedEmotions.contains(emotion) {
//                                selectedEmotions.removeAll(
//                                    where: { $0 == emotion })
//                            } else {
//                                selectedEmotions.append(emotion)
//                            }
//                        }
//                    }
//            }
//        }
//        .padding(8)
//        .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
//    }
//    
//    func EmotionView(_ title: String, isSelected: Bool) -> some View {
//        Text(title)
//            .font(.callout)
//            .foregroundStyle(isSelected ? .white : .primary)
//            .padding(.horizontal, 10)
//            .padding(.vertical, 8)
//            .background(
//                isSelected ? selectedFeeling.color : .white,
//                in: Capsule())
//    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
