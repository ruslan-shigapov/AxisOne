//
//  Persistence.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 27.06.2025.
//

import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "AxisOne")
        if inMemory,
           let containerDescription = container.persistentStoreDescriptions.first {
            containerDescription.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
