//
//  SubgoalSectionView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUI

struct SubgoalSectionView: View {
    
    let selectedLifeArea: LifeAreas
    @Binding var subgoals: [Subgoal]
    @Binding var isModified: Bool
    @Binding var isCompletedHidden: Bool
    
    var body: some View {
        Section {
            AddSubgoalLink()
            SubgoalLinks()
        } header: {
            HeaderView()
        }
    }
    
    private func shouldStrikethrough(
        _ subgoal: Subgoal,
        of type: SubgoalTypes?
    ) -> Bool {
        (type == .task || type == .milestone) && subgoal.isCompleted
    }
}

private extension SubgoalSectionView {
    
    func AddSubgoalLink() -> some View {
        NavigationLink(
            destination: DetailSubgoalView(
                lifeArea: selectedLifeArea,
                subgoals: $subgoals,
                isModified: $isModified)
        ) {
            RowLabelView(type: .link)
        }
    }
    
    func SubgoalLinks() -> some View {
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
                RowSubgoalView(subgoal)
            }
        }
    }
    
    @ViewBuilder
    func RowSubgoalView(_ subgoal: Subgoal) -> some View {
        let type = SubgoalTypes(rawValue: subgoal.type ?? "")
        HStack {
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
    
    func HeaderView() -> some View {
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
                .foregroundStyle(.accent)
                .textCase(.none)
            }
        }
        .font(Constants.Fonts.juraMediumSubheadline)
    }
}
