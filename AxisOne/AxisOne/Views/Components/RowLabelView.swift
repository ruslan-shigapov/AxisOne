//
//  RowLabelView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct RowLabelView: View {
    
    enum RowLabelType: String {
        case link, empty
        
        var color: Color {
            switch self {
            case .link: .accent
            case .empty: .secondary
            }
        }
    }
    
    let type: RowLabelType
    var text: String? = nil
    
    var body: some View {
        Text(text ?? "Добавить")
            .font(Constants.Fonts.juraBody)
            .fontWeight(type != .empty ? .medium : .regular)
            .foregroundStyle(type.color)
    }
}
