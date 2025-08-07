//
//  EmptyStateView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct EmptyStateView: View {
    
    let primaryText: String
    var secondaryText: String?
    
    var body: some View {
        VStack {
            Text(primaryText)
                .fontWeight(.medium)
            Text(secondaryText ?? "")
                .foregroundStyle(.secondary)
        }
        .font(.custom("Jura", size: 17))
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
