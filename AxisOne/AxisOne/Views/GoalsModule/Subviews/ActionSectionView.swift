//
//  ActionSectionView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUI

struct ActionSectionView: View {
    
    let action: () -> Void
    
    var body: some View {
        Section {
            Button("Сделать целью") {
                action()
            }
            .font(Constants.Fonts.juraMediumBody)
            NavigationLink(destination: GoalsView()) {
                RowLabelView(
                    type: .addLink,
                    text: "Привязать к цели")
            }
        }
    }
    
    // TODO: /TASK 1/ превращение входящих в любой тип подцелей
    private func GoalsView() -> some View {
        EmptyView()
    }
}
