//
//  SwipeActionButtonView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct SwipeActionButtonView: View {
    
    enum SwipeActionButtonType: Equatable {
        case delete, toggleActive(isActive: Bool), reschedule
        
        var imageName: String {
            return switch self {
            case .delete: "trash"
            case .toggleActive(let isActive):
                isActive ? "bookmark.slash" : "bookmark"
            case .reschedule: "arrow.up.and.down.text.horizontal"
            }
        }
    }
    
    private var tint: Color? {
        return switch type {
        case .delete: nil
        case .toggleActive(let isActive): isActive ? .gray : activationColor
        case .reschedule: .accent
        }
    }
    
    let type: SwipeActionButtonType
    var activationColor: Color? = nil
    let action: () -> Void
    
    var body: some View {
        Button(role: type == .delete ? .destructive : nil) {
            withAnimation(.snappy) {
                action()
            }
        } label: {
            Image(systemName: type.imageName)
        }
        .tint(tint)
    }
}
