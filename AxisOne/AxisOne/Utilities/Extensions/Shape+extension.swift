//
//  Shape+extension.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.09.2025.
//

import SwiftUICore

extension Shape {
    
    func fillWithShadow() -> some View {
        self.fill(
            .thickMaterial
                .shadow(.drop(color: .black.opacity(0.2), radius: 5)))
    }
}
