//
//  NavBarImageButtonView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct NavBarImageButtonView: View {
    
    enum NavBarImageButtonType {
        case toggleCompletedVisibility, add, cancel
    }
    
    private var imageName: String {
        return switch type {
        case .toggleCompletedVisibility:
            isCompletedHidden?.wrappedValue == true ? "eye" : "eye.slash"
        case .add: "plus.viewfinder"
        case .cancel: "xmark.circle.fill"
        }
    }
    
    let type: NavBarImageButtonType
    
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
