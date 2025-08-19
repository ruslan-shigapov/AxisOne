//
//  SubgoalService+Environment.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 20.08.2025.
//

import SwiftUICore

private struct SubgoalServiceKey: EnvironmentKey {
    
    static var defaultValue: SubgoalService = {
        let context = PersistenceController.shared.container.viewContext
        return SubgoalService(context: context)
    }()
}

extension EnvironmentValues {
    
    var subgoalService: SubgoalService {
        get { self[SubgoalServiceKey.self] }
        set { self[SubgoalServiceKey.self] = newValue }
    }
}
