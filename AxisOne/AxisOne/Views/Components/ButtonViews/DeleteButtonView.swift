//
//  DeleteButtonView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct DeleteButtonView: View {
    
    @State private var isAlertPresented = false

    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(title, role: .destructive) {
            isAlertPresented = true
        }
        .font(Constants.Fonts.juraMediumBody)
        .alert("Вы уверены?", isPresented: $isAlertPresented) {
            Button("Удалить", role: .destructive) {
                action()
            }
            Button("Отмена", role: .cancel) {}
        }
    }
}
