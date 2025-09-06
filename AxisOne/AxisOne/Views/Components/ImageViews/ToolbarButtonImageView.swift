//
//  ToolbarButtonImageView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct ToolbarButtonImageView: View {
    
    enum NavBarImageButtonType: Equatable {
        case toggleVisibility(isActive: Bool), add, cancel, settings, history
        
        var imageName: String {
            switch self {
            case .toggleVisibility(let isActive): isActive ? "eye" : "eye.slash"
            case .add: "plus"
            case .cancel: "xmark.circle.fill"
            case .settings: "gearshape"
            case .history: "list.clipboard"
            }
        }
    }
    
    let type: NavBarImageButtonType
    
    var body: some View {
        Image(systemName: type.imageName)
            .tint(type == .cancel ? .secondary : .accent)
            .fontWeight(type == .add ? .medium : .regular)
    }
}
