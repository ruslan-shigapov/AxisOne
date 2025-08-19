//
//  Color+extension.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUICore

extension Color {
    
    func verticalGradient() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [self.opacity(0.45), self]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
