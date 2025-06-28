//
//  GoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUI

struct GoalView: View {
    
    @State private var isModalViewPresented = false
    
    @ObservedObject var goal: Goal
    
    var body: some View {
        Text(goal.title ?? "")
            .frame(maxWidth: .infinity, alignment: .leading)
            .background()
            .onTapGesture {
                isModalViewPresented = true
            }
            .sheet(isPresented: $isModalViewPresented) {
                DetailGoalView(goal: goal)
            }
    }
}
