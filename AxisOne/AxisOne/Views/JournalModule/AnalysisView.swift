//
//  AnalysisView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct AnalysisView: View {
    
    // MARK: - Private Properties
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest
    private var reflections: FetchedResults<Reflection>
    
    @State private var selectedSubgoal: Subgoal?
    
    @State private var selectedFeeling: Constants.Feelings = .joy
    @State private var selectedGroupedEmotions: [Subgoal: [String]] = [:]
    
    @State private var isExpanded = false
    
    @State private var mainThought = ""
    
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
            Section {
                ForEach(Array(selectedGroupedEmotions.keys)) { subgoal in
                    SubgoalEmotionsView(subgoal)
                        .onTapGesture {
                            selectedSubgoal = subgoal
                        }
                }
            } header: {
                Text("Подцели")
                    .font(.custom("Jura", size: 14))
            }
            Section {
                DisclosureGroup(isExpanded: $isExpanded) {
                    EmotionsView()
                } label: {
                    FeelingPickerView()
                        .disabled(!isExpanded)
                        .padding(.trailing, 8)
                }
            } header: {
                Text("Чувства")
                    .font(.custom("Jura", size: 14))
            } footer: {
                Text("Выберите от 3 до 5 эмоций к каждой подцели для исчерпывающего анализа в будущем.")
                    .font(.custom("Jura", size: 13))
            }
            Section {
                TextField(
                    "Что думаете по этому поводу?",
                    text: $mainThought,
                    axis: .vertical)
                .font(.custom("Jura", size: 17))
            } header: {
                Text("Размышления")
                    .font(.custom("Jura", size: 14))
            }
        }
        .onAppear {
            setupSelectedGroupedEmotions()
            mainThought = reflections.first?.mainThought ?? ""
        }
        .navigationTitle("Самоанализ")
        .background(Constants.Colors.background)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Готово") {
                    save()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
                .font(.custom("Jura", size: 17))
                .fontWeight(.medium)
                .disabled(!isFormValid)
                .foregroundStyle(isFormValid ? .accent : .secondary)
            }
        }
    }
    
    // MARK: - Initialize
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
        let reflectionToSave = reflections.first ?? Reflection(context: context)
        reflectionToSave.date = Date()
        reflectionToSave.timeOfDay = timeOfDay.rawValue
        (reflectionToSave.reactions as? Set<Reaction>)?.forEach {
            context.delete($0)
        }
        for (subgoal, emotions) in selectedGroupedEmotions {
            let reaction = Reaction(context: context)
            reaction.subgoal = subgoal
            reaction.emotions = emotions.joined(separator: " ")
            reflectionToSave.addToReactions(reaction)
        }
        reflectionToSave.mainThought = mainThought
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
                    .filter {
                        !$0.trimmingCharacters(
                            in: .whitespacesAndNewlines).isEmpty
                    }
                selectedGroupedEmotions[subgoal] = emotions
            } else {
                selectedGroupedEmotions[subgoal] = []
            }
        }
        selectedSubgoal = selectedGroupedEmotions.keys.first
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
    
    private func getEmotionCount(of subgoal: Subgoal) -> Int {
        selectedGroupedEmotions[subgoal]?.count ?? 0
    }
}

// MARK: - Views
private extension AnalysisView {
    
    func SubgoalEmotionsView(_ subgoal: Subgoal) -> some View {
        let rawCount = getEmotionCount(of: subgoal)
        return LabeledContent {
            HStack {
                HStack {
                    ForEach(0..<max(min(rawCount, 5), 3), id: \.self) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill($0 < rawCount ? .accent : .gray)
                            .frame(width: 5, height: 15)
                    }
                }
                Image(systemName: subgoal.isCompleted
                      ? "checkmark.circle.fill"
                      : "circle")
                .foregroundStyle(rawCount > 2 ? .accent : .gray)
            }
        } label: {
            Text(subgoal.title ?? "")
                .font(.custom("Jura", size: 17))
                .foregroundStyle(subgoal == selectedSubgoal
                                 ? .primary
                                 : .secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
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
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 4)]) {
            ForEach(selectedFeeling.emotions, id: \.self) { emotion in
                EmotionView(emotion, isSelected: isEmotionSelected(emotion))
                    .onTapGesture {
                        if isEmotionSelected(emotion) {
                            toggleEmotion(emotion)
                        } else if let selectedSubgoal,
                                  getEmotionCount(of: selectedSubgoal) < 5 {
                            toggleEmotion(emotion)
                        }
                    }
            }
        }
        .listRowInsets(EdgeInsets())
        .padding(.trailing, 16)
        .padding(.vertical, 16)
    }
    
    func EmotionView(_ title: String, isSelected: Bool) -> some View {
        Text(title)
            .font(.custom("Jura", size: 14))
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? .accent : .gray.opacity(0.5),
                in: Capsule())
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
