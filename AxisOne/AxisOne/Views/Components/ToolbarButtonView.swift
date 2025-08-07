//
//  ToolbarButtonView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

enum ToolBarButtonType {
    case toggleCompletedVisibility, add, cancel
}

struct ToolbarButtonView: View {
    
    private var imageName: String {
        return switch type {
        case .toggleCompletedVisibility:
            isCompletedHidden?.wrappedValue == true ? "eye" : "eye.slash"
        case .add: "plus"
        case .cancel: "xmark.circle.fill"
        }
    }
    
    let type: ToolBarButtonType
    
    var isCompletedHidden: Binding<Bool>? = nil
    
    var action: () -> Void = {}
    
    var body: some View {
        Button {
            withAnimation {
                if type == .toggleCompletedVisibility {
                    isCompletedHidden?.wrappedValue.toggle()
                } else {
                    action()
                }
            }
        } label: {
            Image(systemName: imageName)
                .fontWeight(type == .add ? .medium : .regular)
                .tint(type == .cancel ? .secondary : .accent)
        }
    }
}
