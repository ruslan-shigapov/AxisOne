//
//  RowTextView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct RowTextView: View {
    
    let primaryText: String
    let secondaryText: String?
    let isActive: Bool
    let isCompleted: Bool
    var activeColor: Color?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(primaryText)
                .font(Constants.Fonts.juraBody)
                .lineLimit(2)
                .foregroundStyle(
                    isActive
                    ? activeColor ?? .red
                    : isCompleted ? .secondary : .primary)
            if let secondaryText, !secondaryText.isEmpty {
                Text(secondaryText)
                    .font(Constants.Fonts.juraLightCallout)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
}
