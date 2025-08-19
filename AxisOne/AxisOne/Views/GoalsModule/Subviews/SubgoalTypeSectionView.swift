//
//  SubgoalTypeSectionView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUI

struct SubgoalTypeSectionView: View {
    
    // MARK: - Private Properties
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Public Properties
    @Binding var selectedSubgoalType: Constants.SubgoalTypes
    let lifeArea: Constants.LifeAreas?
    let completion: () -> Void
    
    // MARK: - Body
    var body: some View {
        Section {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(Constants.SubgoalTypes.allCases.dropLast()) {
                    ChooseButtonView(for: $0)
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(
                Color(
                    colorScheme == .dark
                    ? .systemBackground
                    : .secondarySystemBackground))
        } header: {
            Text("Тип")
                .font(Constants.Fonts.juraSubheadline)
        } footer: {
            Text(selectedSubgoalType.description)
                .font(Constants.Fonts.juraFootnote)
        }
    }
}

// MARK: - Views
private extension SubgoalTypeSectionView {
    
    func ChooseButtonView(for type: Constants.SubgoalTypes) -> some View {
        Button {
            selectedSubgoalType = type
            completion()
        } label: {
            LabeledContent(type.rawValue) {
                Image(systemName: type.imageName)
                    .imageScale(.large)
            }
            .font(Constants.Fonts.juraMediumBody)
            .frame(maxWidth: .infinity, minHeight: 60)
            .foregroundStyle(colorScheme == .dark ? .white : .black)
            .padding(.horizontal)
            .background((lifeArea?.color ?? .clear).verticalGradient())
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        selectedSubgoalType == type ? Color.primary : .clear,
                        lineWidth: 3)
            }
            .cornerRadius(10)
        }
        .buttonStyle(.borderless)
    }
}

#Preview {
    DetailSubgoalView(
        lifeArea: .health,
        subgoals: .constant([]),
        isModified: .constant(false))
}
