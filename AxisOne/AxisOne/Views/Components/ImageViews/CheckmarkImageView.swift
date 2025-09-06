//
//  CheckmarkImageView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct CheckmarkImageView: View {
    
    let isCompleted: Bool
    
    var body: some View {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
            .imageScale(.large)
            .foregroundStyle(.secondary)
    }
}
