//
//  AnalysisView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct AnalysisView: View {
    
    @State private var mainThough = ""
    
    @State private var selectedFeeling: Constants.Feelings = .joy
    @State private var selectedEmotions: [String] = []
    
    var subgoal: Subgoal
    
    var body: some View {
        Form {
            Section(subgoal.type ?? "") {
                Text(subgoal.title ?? "")
            }
            Section("Размышления") {
                MainTextEditorView()
            }
            Section {
                FeelingPickerView()
                EmotionsView()
            } header: {
                Text("Эмоции")
            } footer: {
                Text("Выберите хотя бы 5 эмоций для исчерпывающего анализа в будущем. Но и не переусердствуйте.")
            }

        }
    }
}

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
                EmotionView(emotion, isSelected: selectedEmotions.contains(emotion))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if selectedEmotions.contains(emotion) {
                                selectedEmotions.removeAll(where: { $0 == emotion })
                            } else {
                                selectedEmotions.append(emotion)
                            }
                        }
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
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
