//
//  SwipeActionButtonView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct SwipeActionButtonView: View {
    
    enum SwipeActionButtonType: Equatable {
        case toggleActive(isActive: Bool), delete, reschedule
        
        var imageName: String {
            switch self {
            case .toggleActive(let isActive):
                isActive ? "bookmark.slash" : "bookmark"
            case .delete: "trash"
            case .reschedule: "arrow.up.and.down.text.horizontal"
            }
        }
    }
    
    private var tint: Color? {
        switch type {
        case .toggleActive(let isActive): isActive ? .gray : activationColor
        case .delete: nil
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
