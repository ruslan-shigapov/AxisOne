//
//  RowLabelView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct RowLabelView: View {
    
    enum RowLabelType {
        case addLink, empty
        
        var color: Color {
            return switch self {
            case .addLink: .accent
            case .empty: .secondary
            }
        }
    }
    
    let type: RowLabelType
    var text: String? = nil
    
    var body: some View {
        Text(text ?? "Добавить")
            .font(Constants.Fonts.juraBody)
            .fontWeight(type == .addLink ? .medium : .regular)
            .foregroundStyle(type.color)
    }
}
