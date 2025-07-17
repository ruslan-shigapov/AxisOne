//
//  AnalysisView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct AnalysisView: View {
    
    // MARK: - Private Properties
    @State private var selectedSubgoal: Subgoal?
    
    @State private var selectedFeeling: Constants.Feelings = .joy
    @State private var selectedGroupedEmotions: [Subgoal: [String]] = [:]
    
    @State private var mainThough = ""
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !mainThough.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty /*&&*/
//        selectedEmotions.count > 4
    }
    
    // MARK: - Public Properties
    var subgoals: [Subgoal]
    
    // MARK: - Body
    var body: some View {
        Form {
            Section("Подцели") {
                List {
                    ForEach(subgoals) { subgoal in
                        LabeledContent {
                            HStack {
                                HStack {
                                    ForEach(0..<3) {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(
                                                ($0 < selectedGroupedEmotions[
                                                    subgoal
                                                ]?.count ?? 0)
                                                ? .blue
                                                : .gray)
                                            .frame(width: 5, height: 15)
                                    }
                                }
                                Image(systemName: subgoal.isCompleted
                                      ? "checkmark.circle.fill"
                                      : "circle")
                            }
                        } label: {
                            Text(subgoal.title ?? "")
                                .fontWeight(subgoal == selectedSubgoal
                                            ? .semibold : .regular)
                        }
                        .onTapGesture {
                            selectedSubgoal = subgoal
                        }
                    }
                }
            }
            Section {
                FeelingPickerView()
                EmotionsView()
            } header: {
                Text("Эмоции")
            } footer: {
                Text("Выберите хотя бы 5 эмоций для исчерпывающего анализа в будущем. Но и не переусердствуйте.")
            }
            Section("Размышления") {
                MainTextEditorView()
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
                .disabled(!isFormValid)
                .foregroundStyle(isFormValid ? .blue : .secondary)
            }
        }
    }
    
    init(selectedSubgoal: Subgoal? = nil, subgoals: [Subgoal]) {
        self.subgoals = subgoals
        _selectedSubgoal = State(initialValue: subgoals.first)
    }
    
    // MARK: - Private Methods
    private func save() {
        let reflection = Reflection(context: context)
        reflection.date = Date()
        reflection.mainThough = mainThough
        subgoals.forEach {
            let response = Reaction(context: context)
            response.subgoal = $0
//        reflection.emotions = selectedEmotions.joined(separator: " ")
//            reflection.addToResponses(response)
        }
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
    
    func FeelingPickerView() -> some View {
        Picker("", selection: $selectedFeeling) {
            ForEach(Constants.Feelings.allCases) {
                Text($0.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 4)
    }

    func EmotionsView() -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 4)]) {
            ForEach(selectedFeeling.emotions, id: \.self) { emotion in
                EmotionView(emotion, isSelected: isEmotionSelected(emotion))
                    .onTapGesture {
                        toggleEmotion(emotion)
                    }
            }
        }
        .padding(8)
        .background(.gray.opacity(0.1), in: .rect(cornerRadius: 16))
    }
    
    func EmotionView(_ title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.callout)
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                isSelected ? selectedFeeling.color : .white,
                in: Capsule())
    }
    
    private func isEmotionSelected(_ emotion: String) -> Bool {
        guard let subgoal = selectedSubgoal else { return false }
        return (selectedGroupedEmotions[subgoal] ?? []).contains(emotion)
    }
    
    private func toggleEmotion(_ emotion: String) {
        guard let subgoal = selectedSubgoal else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            var emotions = selectedGroupedEmotions[subgoal] ?? []
            if emotions.contains(emotion) {
                emotions.removeAll(where: { $0 == emotion })
            } else {
                emotions.append(emotion)
            }
            selectedGroupedEmotions[subgoal] = emotions
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
