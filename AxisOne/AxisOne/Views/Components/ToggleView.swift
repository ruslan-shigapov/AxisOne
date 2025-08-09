//
//  ToggleView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 09.08.2025.
//

import SwiftUI

struct ToggleView: View {
    
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(title, isOn: $isOn)
            .font(.custom("Jura", size: 17))
            .tint(.accent)
    }
}
