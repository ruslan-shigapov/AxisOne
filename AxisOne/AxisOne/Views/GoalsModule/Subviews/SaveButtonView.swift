//
//  SaveButtonView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUI

struct SaveButtonView: View {
    
    let action: () -> Void
    
    var body: some View {
        Button("Сохранить") {
            action()
        }
        .font(Constants.Fonts.juraMediumBody)
        .frame(maxWidth: .infinity)
    }
}
