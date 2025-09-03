//
//  TabBarView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 02.09.2025.
//

import SwiftUI

struct TabBarView: View {
        
    @Binding var activeTab: Constants.Tabs
    
    var body: some View {
        HStack {
            ForEach(Constants.Tabs.allCases) {
                TabButtonView($0)
            }
        }
        .frame(height: 50)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    .thickMaterial
                        .shadow(.drop(color: .primary.opacity(0.2), radius: 5)))
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
    
    @ViewBuilder
    private func TabButtonView(_ tab: Constants.Tabs) -> some View {
        let isActive = activeTab == tab
        VStack(spacing: 3) {
            Image(systemName: tab.iconName)
                .symbolVariant(.fill)
            Text(tab.rawValue)
                .font(Constants.Fonts.juraMediumFootnote)
        }
        .foregroundStyle(isActive ? .white : .secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if isActive {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.accent)
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            withAnimation(.snappy) {
                activeTab = tab
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
