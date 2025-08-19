//
//  GoalService+Environment.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUICore

private struct GoalServiceKey: EnvironmentKey {
    
    static var defaultValue: GoalService = {
        let context = PersistenceController.shared.container.viewContext
        return GoalService(context: context)
    }()
}

extension EnvironmentValues {
    
    var goalService: GoalService {
        get { self[GoalServiceKey.self] }
        set { self[GoalServiceKey.self] = newValue }
    }
}
