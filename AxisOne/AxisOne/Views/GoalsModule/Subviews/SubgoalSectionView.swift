//
//  SubgoalSectionView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUI

struct SubgoalSectionView: View {
    
    let selectedLifeArea: Constants.LifeAreas
    @Binding var subgoals: [Subgoal]
    @Binding var isModified: Bool
    @Binding var isCompletedHidden: Bool
    
    var body: some View {
        Section {
            NavigationLink(
                destination: DetailSubgoalView(
                    lifeArea: selectedLifeArea,
                    subgoals: $subgoals,
                    isModified: $isModified)
            ) {
                RowLabelView(type: .addLink)
            }
            SubgoalsView()
        } header: {
            SubgoalSectionHeaderView()
        }
    }
    
    private func shouldStrikethrough(
        _ subgoal: Subgoal,
        of type: Constants.SubgoalTypes?
    ) -> Bool {
        (type == .task || type == .milestone) && subgoal.isCompleted
    }
}

private extension SubgoalSectionView {
    
    func SubgoalsView() -> some View {
        ForEach(
            subgoals.filter { !isCompletedHidden || !$0.isCompleted }
        ) { subgoal in
            NavigationLink(
                destination: DetailSubgoalView(
                    lifeArea: selectedLifeArea,
                    subgoal: subgoal,
                    subgoals: $subgoals,
                    isModified: $isModified)
            ) {
                SubgoalRowView(subgoal)
            }
        }
    }
    
    func SubgoalRowView(_ subgoal: Subgoal) -> some View {
        let type = Constants.SubgoalTypes(rawValue: subgoal.type ?? "")
        return HStack {
            Image(systemName: type?.imageName ?? "")
                .imageScale(.large)
                .foregroundStyle(.secondary)
            Text(subgoal.title ?? "")
                .lineLimit(2)
                .foregroundStyle(subgoal.isCompleted ? .secondary : .primary)
                .strikethrough(shouldStrikethrough(subgoal, of: type))
        }
        .font(Constants.Fonts.juraBody)
    }
    
    func SubgoalSectionHeaderView() -> some View {
        LabeledContent("Подцели") {
            Button {
                withAnimation(.snappy) {
                    isCompletedHidden.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(isCompletedHidden ? "Показать" : "Скрыть")
                    Text("заверш.")
                }
                .textCase(.none)
            }
        }
        .font(Constants.Fonts.juraMediumSubheadline)
    }
}
