//
//  View+extension.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 09.09.2025.
//

import SwiftUI

extension View {
    
    func deleteAlert(
        isPresented: Binding<Bool>,
        messageText: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        self.alert("Вы уверены?", isPresented: isPresented) {
            Button(Constants.Texts.delete, role: .destructive) {
                action()
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            if let messageText {
                Text(messageText)
            }
        }
    }
}
