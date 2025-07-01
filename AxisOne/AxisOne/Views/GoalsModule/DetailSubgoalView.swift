//
//  DetailSubgoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct DetailSubgoalView: View {
        
    var subgoal: Subgoal?
    
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .navigationTitle(subgoal == nil ? "Новая подцель" : "Детали")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    DetailSubgoalView()
}
