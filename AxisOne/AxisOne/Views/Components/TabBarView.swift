//
//  TabBarView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 02.09.2025.
//

import SwiftUI

struct TabBarView: View {
        
    @Binding var activeTab: Tabs
    
    var body: some View {
        HStack {
            ForEach(Tabs.allCases) {
                TabButtonView($0)
            }
        }
        .frame(height: 60)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    .thickMaterial
                        .shadow(.drop(color: .primary.opacity(0.2), radius: 5)))
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
}

private extension TabBarView {
    
    func TabButtonView(_ tab: Tabs) -> some View {
        VStack(spacing: 3) {
            Image(systemName: tab.imageName)
                .imageScale(.large)
                .symbolVariant(.fill)
            Text(tab.rawValue)
                .font(Constants.Fonts.juraMediumFootnote)
        }
        .foregroundStyle(activeTab == tab ? .white : .secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if activeTab == tab {
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
