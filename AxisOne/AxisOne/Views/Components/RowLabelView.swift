//
//  RowLabelView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct RowLabelView: View {
    
    enum RowLabelType: String {
        case addLink = "Добавить"
        case empty = ""
        
        var color: Color {
            return switch self {
            case .empty: .secondary
            default: .accent
            }
        }
    }
    
    let type: RowLabelType
    var text: String? = nil
    
    var body: some View {
        Text(text ?? type.rawValue)
            .font(Constants.Fonts.juraBody)
            .fontWeight(type != .empty ? .medium : .regular)
            .foregroundStyle(type.color)
    }
}
