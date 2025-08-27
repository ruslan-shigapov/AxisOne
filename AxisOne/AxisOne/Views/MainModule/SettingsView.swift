//
//  SettingsView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        List {
            
        }
        .navigationTitle("Настройки")
        .background(
            colorScheme == .dark
            ? Constants.Colors.darkBackground
            : Constants.Colors.lightBackground)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    SettingsView()
}
