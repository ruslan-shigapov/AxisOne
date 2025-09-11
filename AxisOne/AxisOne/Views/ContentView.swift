//
//  ContentView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 27.06.2025.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.subgoalService) private var subgoalService
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedTab: Tabs = .journal
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tabs.allCases) { tab in
                NavigationStack {
                    tab.view
                        .navigationTitle(tab.rawValue)
                        .toolbar(tab == .main ? .hidden : .visible)
                        .toolbar(.hidden, for: .tabBar)
                        .background(Color("Background"))
                        .scrollContentBackground(.hidden)
                        .safeAreaInset(edge: .bottom) {
                            ZStack(alignment: .bottom) {
                                MaskedRectangle()
                                TabBarView(activeTab: $selectedTab)
                            }
                        }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .onAppear {
            do {
                try subgoalService.resetDailyValues()
                // TODO: добавить типа таймер 
            } catch {
                print(error)
            }
        }
    }
}

private extension ContentView {
    
    func MaskedRectangle() -> some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black]),
                    startPoint: .top,
                    endPoint: .bottom))
            .frame(height: 100)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
