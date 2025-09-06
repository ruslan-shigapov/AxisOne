//
//  ToolbarTextButtonView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 09.08.2025.
//

import SwiftUI

struct ToolbarTextButtonView: View {
    
    enum NavBarTextButtonType {
        case edit(isActive: Bool), cancel, done
        
        var title: String {
            switch self {
            case .edit(let isActive):
                isActive ? Constants.Texts.done : Constants.Texts.edit
            case .cancel: Constants.Texts.cancel
            case .done: Constants.Texts.done
            }
        }
    }
    
    let type: NavBarTextButtonType
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(type.title)
                .font(Constants.Fonts.juraBody)
                .fontWeight(
                    type.title == Constants.Texts.done ? .bold : .medium)
        }
    }
}
