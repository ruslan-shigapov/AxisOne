//
//  RowLabelView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct RowLabelView: View {
    
    enum RowLabelType {
        case addLink
        case empty
    }
    
    private var color: Color {
        return switch type {
        case .addLink: .accent
        case .empty: .secondary
        }
    }
    
    let type: RowLabelType
    
    let text: String
    
    var body: some View {
        Text(text)
            .font(.custom("Jura-Medium", size: 17))
            .foregroundStyle(color)
    }
}
