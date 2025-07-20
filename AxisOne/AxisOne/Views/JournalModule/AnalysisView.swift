//
//  AnalysisView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct AnalysisView: View {
    
    // MARK: - Private Properties
    @FetchRequest
    private var reflections: FetchedResults<Reflection>
    
    @State private var selectedSubgoal: Subgoal?
    
    @State private var selectedFeeling: Constants.Feelings = .joy
    @State private var selectedGroupedEmotions: [Subgoal: [String]] = [:]
    
    @State private var mainThought = ""
    
    @State private var isSectionExpanded = true
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    private var isFormValid: Bool {
        !mainThought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedGroupedEmotions.allSatisfy { $0.value.count > 2 }
    }
    
    private var reactions: [Reaction] {
        reflections
            .compactMap { $0.reactions as? Set<Reaction> }
            .flatMap { $0 }
    }
    
    // MARK: - Public Properties
    var timeOfDay: Constants.TimesOfDay
    var subgoals: [Subgoal]

    // MARK: - Body
    var body: some View {
        Form {
            Section("Подцели") {
                ForEach(Array(selectedGroupedEmotions.keys)) { subgoal in
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
                            .foregroundStyle(
                                (selectedGroupedEmotions[
                                    subgoal
                                ]?.count ?? 0) > 2
                                ? .blue
                                : .gray)
                        }
                    } label: {
                        Text(subgoal.title ?? "")
                            .foregroundStyle(subgoal == selectedSubgoal
                                             ? .primary
                                             : .secondary)
                    }
                    .onTapGesture {
                        selectedSubgoal = subgoal
                    }
                }
            }
            Section("Размышления") {
                TextField(
                    "Что думаете по этому поводу?",
                    text: $mainThought,
                    axis: .vertical)
            }
            Section {
                FeelingPickerView()
                EmotionsView()
            } header: {
                Text("Эмоции")
            } footer: {
                Text("Выберите хотя бы по 3 эмоции к каждой подцели для исчерпывающего анализа в будущем. Но и не переусердствуйте.")
            }
        }
        .onAppear {
            setupSelectedGroupedEmotions()
            mainThought = reflections.first?.mainThought ?? ""
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
    
    init(
        timeOfDay: Constants.TimesOfDay,
        subgoals: [Subgoal],
    ) {
        self.timeOfDay = timeOfDay
        self.subgoals = subgoals
        _reflections = FetchRequest(
            entity: Reflection.entity(),
            sortDescriptors: [],
            predicate: ReflectionFilter.predicate(
                for: .now,
                timeOfDay: timeOfDay))
    }
    
    // MARK: - Private Methods
    private func save() {
        let reflection = reflections.first ?? Reflection(context: context)
        reflection.date = Date()
        reflection.timeOfDay = timeOfDay.rawValue
        reflection.mainThought = mainThought
        (reflection.reactions as? Set<Reaction>)?.forEach {
            context.delete($0)
        }
        for (subgoal, emotions) in selectedGroupedEmotions {
            let reaction = Reaction(context: context)
            reaction.subgoal = subgoal
            reaction.emotions = emotions.joined(separator: " ")
            reflection.addToReactions(reaction)
        }
        try? context.save()
    }
    
    private func setupSelectedGroupedEmotions() {
        let reactions = reflections
            .compactMap { $0.reactions as? Set<Reaction> }
            .flatMap { $0 }
        subgoals.forEach { subgoal in
            if let reaction = reactions.first(where: {
                $0.subgoal?.title == subgoal.title
            }) {
                let emotions = reaction.emotions?
                    .components(separatedBy: " ")
                    .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                selectedGroupedEmotions[subgoal] = emotions
            } else {
                selectedGroupedEmotions[subgoal] = []
            }
        }
        selectedSubgoal = selectedGroupedEmotions.keys.first
    }
}

// MARK: - Views
private extension AnalysisView {
    
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
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 4)]) {
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
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                isSelected ? selectedFeeling.color : .gray.opacity(0.5),
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
