//
//  AnalysisView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 05.07.2025.
//

import SwiftUI

struct AnalysisView: View {
    
    var subgoal: Subgoal
    
    var body: some View {
        Text(subgoal.title ?? "")
    }
}
