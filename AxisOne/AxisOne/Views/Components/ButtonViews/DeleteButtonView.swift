//
//  DeleteButtonView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct DeleteButtonView: View {
    
    @State private var isAlertPresented = false

    var message: String?
    let action: () -> Void
    
    var body: some View {
        Button(Constants.Texts.delete, role: .destructive) {
            isAlertPresented = true
        }
        .font(Constants.Fonts.juraMediumBody)
        .deleteAlert(
            isPresented: $isAlertPresented,
            messageText: message,
            action: action)
    }
}
