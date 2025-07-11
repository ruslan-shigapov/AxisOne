//
//  SubgoalView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct SubgoalView: View {
    
    @ObservedObject var subgoal: Subgoal
    
    var body: some View {
        HStack {
            Image(
                systemName: (
                    Constants.SubgoalTypes(
                        rawValue: subgoal.type ?? "")?.imageName) ?? "")
                .font(.system(size: 22))
                .foregroundStyle(.secondary)
            Text(subgoal.title ?? "")
        }
    }
}
