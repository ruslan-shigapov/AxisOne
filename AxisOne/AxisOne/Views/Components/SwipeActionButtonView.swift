//
//  SwipeActionButtonView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct SwipeActionButtonView: View {
    
    enum SwipeActionButtonType {
        case delete, toggleActive, move
        
        var role: ButtonRole? {
            return switch self {
            case .delete: .destructive
            default: nil
            }
        }
    }
    
    private var imageName: String {
        return switch type {
        case .delete: "trash"
        case .toggleActive: isActive?.wrappedValue == true
            ? "bookmark.slash"
            : "bookmark"
        case .move: "move.3d"
        }
    }
    
    private var tint: Color? {
        return switch type {
        case .delete: nil
        case .toggleActive: isActive?.wrappedValue == true
            ? .gray
            : activationColor
        case .move: .accent
        }
    }
    
    let type: SwipeActionButtonType
    
    var isActive: Binding<Bool>? = nil
    var activationColor: Color? = nil
    
    let action: () -> Void
    
    var body: some View {
        Button(role: type.role) {
            withAnimation {
                action()
            }
        } label: {
            Image(systemName: imageName)
        }
        .tint(tint)
    }
}
