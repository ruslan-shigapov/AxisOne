//
//  HeaderWithToggleView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct HeaderWithToggleView<Content: View>: View {
    
    let title: Content
    let contentName: String
    
    @Binding var isContentHidden: Bool
    
    var body: some View {
        LabeledContent {
            Button {
                withAnimation {
                    isContentHidden.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(isContentHidden ? "Показать" : "Скрыть")
                    Text(contentName)
                }
            }
        } label: {
            title
        }
        .font(.custom("Jura", size: 14))
    }
}
