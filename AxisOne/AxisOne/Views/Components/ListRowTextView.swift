//
//  ListRowTextView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct ListRowTextView: View {
    
    let primaryText: String?
    let secondaryText: String?
        
    @Binding var isActive: Bool
    @Binding var isCompleted: Bool
    
    var activeColor: Color?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(primaryText ?? "")
                .font(.custom("Jura-Medium", size: 17))
                .lineLimit(2)
                .foregroundStyle(isActive
                                 ? activeColor ?? .red
                                 : isCompleted ? .secondary : .primary)
            if let secondaryText, !secondaryText.isEmpty {
                Text(secondaryText)
                    .font(.custom("Jura-Light", size: 17))
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
