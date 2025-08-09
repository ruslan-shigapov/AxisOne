//
//  NavBarLabelButtonView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 09.08.2025.
//

import SwiftUI

struct NavBarLabelButtonView: View {
    
    enum NavBarLabelButtonType {
        case edit, cancel, done
    }
    
    private let doneTitle = "Готово"
    
    private var title: String {
        return switch type {
        case .edit:
            isEditModeActive == true ? doneTitle : "Править"
        case .cancel: "Отменить"
        case .done: doneTitle
        }
    }
    
    let type: NavBarLabelButtonType
    
    var isEditModeActive: Bool? = nil
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.custom("Jura", size: 17))
                .fontWeight(title == doneTitle ? .bold : .medium)
        }
    }
}
