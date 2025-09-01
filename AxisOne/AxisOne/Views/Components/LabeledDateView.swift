//
//  LabeledDateView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUI

struct LabeledDateView: View {
    
    let title: String
    let value: String
    
    var body: some View {
        LabeledContent(title) {
            Text(value)
                .foregroundStyle(.accent)
                .fontWeight(.medium)
        }
        .font(Constants.Fonts.juraBody)
        .contentShape(.rect)
    }
}
